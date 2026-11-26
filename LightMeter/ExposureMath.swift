import Foundation

enum PriorityMode: Equatable {
    case shutter // 快门优先：用户定快门，算光圈
    case aperture // 光圈优先：用户定光圈，算快门
}

struct ExposureSettings: Equatable {
    var iso: Double
    var aperture: Double
    var shutter: Double // seconds
}

enum ExposureMath {
    /// Scene brightness at ISO 100 from a correctly exposed camera reading.
    static func ev100(aperture: Double, shutter: Double, iso: Double) -> Double {
        guard aperture > 0, shutter > 0, iso > 0 else { return .nan }
        let cameraEV = log2((aperture * aperture) / shutter)
        return cameraEV - log2(iso / 100.0)
    }

    /// Effective EV after photographer exposure compensation.
    static func effectiveEV(measured: Double, compensation: Double) -> Double {
        guard measured.isFinite else { return .nan }
        return measured + compensation
    }

    static func lux(fromEV100 ev: Double) -> Double {
        guard ev.isFinite else { return .nan }
        return 2.5 * pow(2.0, ev)
    }

    static func shutter(ev100: Double, aperture: Double, iso: Double) -> Double {
        guard ev100.isFinite, aperture > 0, iso > 0 else { return .nan }
        let isoFactor = iso / 100.0
        return (aperture * aperture) / (pow(2.0, ev100) * isoFactor)
    }

    static func aperture(ev100: Double, shutter: Double, iso: Double) -> Double {
        guard ev100.isFinite, shutter > 0, iso > 0 else { return .nan }
        let isoFactor = iso / 100.0
        return sqrt(pow(2.0, ev100) * shutter * isoFactor)
    }

    /// Resolve the dependent side for the active priority mode.
    static func resolve(ev100: Double, settings: ExposureSettings, mode: PriorityMode) -> ExposureSettings {
        var next = settings
        switch mode {
        case .shutter:
            let value = aperture(ev100: ev100, shutter: settings.shutter, iso: settings.iso)
            next.aperture = nearest(value, in: apertureStops)
        case .aperture:
            let value = shutter(ev100: ev100, aperture: settings.aperture, iso: settings.iso)
            next.shutter = nearest(value, in: shutterStops)
        }
        return next
    }

    static let isoStops: [Double] = [
        25, 50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800,
        1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400
    ]

    static let apertureStops: [Double] = [
        1.0, 1.2, 1.4, 1.8, 2.0, 2.2, 2.5, 2.8, 3.2, 3.5, 4.0, 4.5, 5.0, 5.6,
        6.3, 7.1, 8.0, 9.0, 10.0, 11.0, 13.0, 14.0, 16.0, 18.0, 20.0, 22.0
    ]

    static let shutterStops: [Double] = [
        1.0 / 8000, 1.0 / 4000, 1.0 / 2000, 1.0 / 1000, 1.0 / 500, 1.0 / 250,
        1.0 / 125, 1.0 / 60, 1.0 / 30, 1.0 / 15, 1.0 / 8, 1.0 / 4, 1.0 / 2,
        1.0, 2.0, 4.0, 8.0, 15.0, 30.0
    ]

    /// Exposure compensation in 1/3-stop steps from −2 to +2.
    static let compensationStops: [Double] = (-6...6).map { Double($0) / 3.0 }

    static func nearest(_ value: Double, in stops: [Double]) -> Double {
        guard value.isFinite, let first = stops.first else { return value }
        return stops.min(by: { abs($0 - value) < abs($1 - value) }) ?? first
    }

    static func formatShutter(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds > 0 else { return "—" }
        if seconds >= 1 {
            if abs(seconds - seconds.rounded()) < 0.05 {
                return "\(Int(seconds.rounded()))″"
            }
            return String(format: "%.1f″", seconds)
        }
        let denom = Int((1.0 / seconds).rounded())
        return "1/\(denom)"
    }

    static func formatAperture(_ f: Double) -> String {
        guard f.isFinite else { return "—" }
        if abs(f - f.rounded()) < 0.05 {
            return "f/\(Int(f.rounded()))"
        }
        return String(format: "f/%.1f", f)
    }

    static func formatISO(_ iso: Double) -> String {
        guard iso.isFinite else { return "—" }
        return "ISO \(Int(iso.rounded()))"
    }

    static func formatEVCompact(_ ev: Double) -> String {
        guard ev.isFinite else { return "EV —" }
        return String(format: "EV %.1f", ev)
    }

    static func formatCompensation(_ stops: Double) -> String {
        guard stops.isFinite else { return "±0" }
        if abs(stops) < 0.05 {
            return "±0"
        }
        return String(format: "%+.1f", stops)
    }
}
