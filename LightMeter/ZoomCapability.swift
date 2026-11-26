import AVFoundation
import Foundation

enum ZoomCapability {
    /// UI / Camera-app style multipliers (0.5, 1, 2, 3…), not raw `videoZoomFactor`.
    static func probeDisplayStops(for device: AVCaptureDevice) -> [Double] {
        let wide = wideEquivalentDeviceZoom(for: device)
        let minDisplay = Double(device.minAvailableVideoZoomFactor) / wide
        let maxDisplay = Double(device.maxAvailableVideoZoomFactor) / wide

        var stops: [Double] = []

        if minDisplay < 0.9 {
            stops.append(roundStop(minDisplay)) // typically 0.5
        }

        stops.append(1.0)

        // System Camera often exposes 1.5 as a primary control on multi-cam phones.
        if maxDisplay >= 1.45 {
            stops.append(1.5)
        }

        for number in device.virtualDeviceSwitchOverVideoZoomFactors {
            let display = roundStop(Double(truncating: number) / wide)
            // Skip the ultra-wide → wide switch (that's display 1x).
            if display > 1.05 && display <= maxDisplay + 0.05 {
                stops.append(display)
            }
        }

        let unique = Array(Set(stops.map { roundStop($0) }))
            .filter { $0 >= minDisplay - 0.05 && $0 <= maxDisplay + 0.05 }
            .sorted()

        return unique.isEmpty ? [1.0] : unique
    }

    /// Device `videoZoomFactor` that matches Camera-app **1x** (main wide FOV).
    /// On dual-wide / triple cameras this is usually 2.0 (ultra-wide sits at 1.0).
    static func wideEquivalentDeviceZoom(for device: AVCaptureDevice) -> Double {
        switch device.deviceType {
        case .builtInTripleCamera, .builtInDualWideCamera:
            if let first = device.virtualDeviceSwitchOverVideoZoomFactors.first {
                return Double(truncating: first)
            }
            return 2.0
        default:
            return 1.0
        }
    }

    static func deviceZoom(fromDisplay display: Double, device: AVCaptureDevice) -> Double {
        let wide = wideEquivalentDeviceZoom(for: device)
        return display * wide
    }

    static func preferredBackCamera() -> AVCaptureDevice? {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .back
        )
        return session.devices.first
    }

    static func clamp(_ zoom: Double, to stops: [Double]) -> Double {
        guard !stops.isEmpty else { return 1.0 }
        return stops.min(by: { abs($0 - zoom) < abs($1 - zoom) }) ?? 1.0
    }

    static func format(_ zoom: Double) -> String {
        if abs(zoom - 1.0) < 0.05 {
            return "1x"
        }
        if abs(zoom - zoom.rounded()) < 0.05 {
            return "\(Int(zoom.rounded()))"
        }
        return String(format: "%.1f", zoom)
    }

    private static func roundStop(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }
}
