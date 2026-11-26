import AVFoundation
import Combine
import SwiftUI

final class CameraMeter: NSObject, ObservableObject {
    @Published private(set) var liveEV100: Double = .nan
    @Published private(set) var heldEV100: Double?
    @Published private(set) var isRunning = false
    @Published private(set) var permissionDenied = false
    @Published private(set) var statusMessage = String(localized: "status.starting")
    @Published private(set) var deviceAperture: Double = 1.8
    @Published private(set) var availableZooms: [Double]
    @Published private(set) var zoomFactor: Double

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "lightmeter.camera")
    private var device: AVCaptureDevice?
    private var isConfigured = false
    private var smoothedEV: Double = .nan
    private var meterTimer: DispatchSourceTimer?

    var displayedEV100: Double {
        heldEV100 ?? liveEV100
    }

    var isHolding: Bool {
        heldEV100 != nil
    }

    var showsZoomControls: Bool {
        availableZooms.count >= 2
    }

    override init() {
        let cached = MeterPreferences.loadAvailableZooms()
        let savedZoom = MeterPreferences.load().selectedZoom
        availableZooms = cached ?? [1.0]
        zoomFactor = ZoomCapability.clamp(savedZoom, to: cached ?? [1.0])
        super.init()
    }

    @MainActor
    func start() async {
        #if targetEnvironment(simulator)
        permissionDenied = false
        isRunning = true
        statusMessage = String(localized: "status.simulator")
        // Simulator: no multi-cam — keep single 1x and hide zoom UI.
        availableZooms = [1.0]
        zoomFactor = 1.0
        startSimulatorMetering()
        return
        #else
        let granted = await requestAccess()
        guard granted else {
            permissionDenied = true
            statusMessage = String(localized: "status.camera_required")
            return
        }
        permissionDenied = false
        statusMessage = String(localized: "status.point_subject")

        let initialZoom = zoomFactor
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }
                self.configureIfNeeded()
                self.applyZoomFactor(initialZoom, resetSmoothing: true)
                if !self.session.isRunning {
                    self.session.startRunning()
                }
                self.startMeteringTimer()
                DispatchQueue.main.async {
                    self.isRunning = true
                    self.statusMessage = String(localized: "status.point_subject")
                    continuation.resume()
                }
            }
        }
        #endif
    }

    #if targetEnvironment(simulator)
    @MainActor
    private func startSimulatorMetering() {
        Task { @MainActor in
            var t = 0.0
            while isRunning {
                if heldEV100 == nil {
                    liveEV100 = 12.5 + sin(t) * 1.4
                    statusMessage = String(localized: "status.simulator")
                }
                t += 0.12
                try? await Task.sleep(nanoseconds: 120_000_000)
            }
        }
    }
    #endif

    func stop() {
        sessionQueue.async { [weak self] in
            self?.meterTimer?.cancel()
            self?.meterTimer = nil
            if self?.session.isRunning == true {
                self?.session.stopRunning()
            }
            DispatchQueue.main.async {
                self?.isRunning = false
            }
        }
    }

    @MainActor
    func setZoomFactor(_ factor: Double) {
        let clamped = ZoomCapability.clamp(factor, to: availableZooms)
        guard abs(clamped - zoomFactor) > 0.01 else { return }
        zoomFactor = clamped
        sessionQueue.async { [weak self] in
            self?.applyZoomFactor(clamped, resetSmoothing: true)
        }
    }

    @MainActor
    func toggleHold() {
        if heldEV100 != nil {
            heldEV100 = nil
            statusMessage = String(localized: "status.live")
        } else if liveEV100.isFinite {
            heldEV100 = liveEV100
            statusMessage = String(localized: "status.held")
        }
    }

    private func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    /// Must run on `sessionQueue`.
    private func configureIfNeeded() {
        guard !isConfigured else { return }
        session.beginConfiguration()
        session.sessionPreset = .high

        guard
            let camera = ZoomCapability.preferredBackCamera(),
            let input = try? AVCaptureDeviceInput(device: camera),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.statusMessage = String(localized: "status.no_camera")
            }
            return
        }

        session.addInput(input)
        device = camera

        let stops: [Double]
        if let cached = MeterPreferences.loadAvailableZooms(), !cached.isEmpty {
            stops = cached
        } else {
            stops = ZoomCapability.probeDisplayStops(for: camera)
            MeterPreferences.saveAvailableZooms(stops)
        }

        do {
            try camera.lockForConfiguration()
            if camera.isExposureModeSupported(.continuousAutoExposure) {
                camera.exposureMode = .continuousAutoExposure
            }
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            }
            camera.unlockForConfiguration()
        } catch {
            // Continue with defaults.
        }

        let aperture = Double(camera.lensAperture)
        let clampedZoom = ZoomCapability.clamp(zoomFactor, to: stops)
        DispatchQueue.main.async {
            self.availableZooms = stops
            self.zoomFactor = clampedZoom
            self.deviceAperture = aperture > 0 ? aperture : 1.8
        }

        session.commitConfiguration()
        isConfigured = true
    }

    /// Must run on `sessionQueue`.
    /// - Parameter factor: Camera-app style display zoom (0.5 / 1 / 2 / 3…), not raw `videoZoomFactor`.
    private func applyZoomFactor(_ factor: Double, resetSmoothing: Bool) {
        guard let device else { return }
        let minZ = device.minAvailableVideoZoomFactor
        let maxZ = device.maxAvailableVideoZoomFactor
        let deviceZoom = ZoomCapability.deviceZoom(fromDisplay: factor, device: device)
        let clamped = CGFloat(deviceZoom).clamped(to: minZ...maxZ)
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
            if resetSmoothing {
                smoothedEV = .nan
            }
        } catch {
            // Keep previous zoom.
        }
    }

    /// Must run on `sessionQueue`.
    private func startMeteringTimer() {
        meterTimer?.cancel()
        let timer = DispatchSource.makeTimerSource(queue: sessionQueue)
        timer.schedule(deadline: .now(), repeating: 0.12)
        timer.setEventHandler { [weak self] in
            self?.sampleExposure()
        }
        meterTimer = timer
        timer.resume()
    }

    /// Must run on `sessionQueue`.
    private func sampleExposure() {
        guard let device, session.isRunning else { return }

        let iso = Double(device.iso)
        let shutter = CMTimeGetSeconds(device.exposureDuration)
        let aperture = Double(device.lensAperture)
        let N = aperture > 0 ? aperture : 1.8
        let sample = ExposureMath.ev100(aperture: N, shutter: shutter, iso: iso)

        guard sample.isFinite else { return }

        if smoothedEV.isFinite {
            smoothedEV = smoothedEV * 0.82 + sample * 0.18
        } else {
            smoothedEV = sample
        }
        let value = smoothedEV
        DispatchQueue.main.async {
            self.liveEV100 = value
            self.deviceAperture = N
            if self.heldEV100 == nil {
                self.statusMessage = String(localized: "status.point_subject")
            }
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
