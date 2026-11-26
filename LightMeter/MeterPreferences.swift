import Foundation

/// Persists user-chosen settings and one-time zoom capability probe.
enum MeterPreferences {
    private static let defaults = UserDefaults.standard

    private enum Key {
        static let iso = "meter.iso"
        static let compensation = "meter.compensation"
        static let priority = "meter.priority"
        static let userShutter = "meter.userShutter"
        static let userAperture = "meter.userAperture"
        /// v2 stores Camera-app style display zooms (0.5/1/2/3), not raw videoZoomFactor.
        static let availableZooms = "meter.availableZooms.v2"
        static let selectedZoom = "meter.selectedZoom.v2"
    }

    struct Snapshot {
        var iso: Double
        var compensation: Double
        var priority: PriorityMode
        var userShutter: Double
        var userAperture: Double
        var selectedZoom: Double
    }

    static let fallback = Snapshot(
        iso: 400,
        compensation: 0,
        priority: .shutter,
        userShutter: 1.0 / 125,
        userAperture: 2.8,
        selectedZoom: 1.0
    )

    static func load() -> Snapshot {
        let iso = defaults.object(forKey: Key.iso) as? Double ?? fallback.iso
        let compensation = defaults.object(forKey: Key.compensation) as? Double ?? fallback.compensation
        let priorityRaw = defaults.string(forKey: Key.priority) ?? "shutter"
        let priority: PriorityMode = priorityRaw == "aperture" ? .aperture : .shutter
        let userShutter = defaults.object(forKey: Key.userShutter) as? Double ?? fallback.userShutter
        let userAperture = defaults.object(forKey: Key.userAperture) as? Double ?? fallback.userAperture
        let selectedZoom = defaults.object(forKey: Key.selectedZoom) as? Double ?? fallback.selectedZoom

        return Snapshot(
            iso: iso,
            compensation: ExposureMath.nearest(compensation, in: ExposureMath.compensationStops),
            priority: priority,
            userShutter: userShutter > 0 ? userShutter : fallback.userShutter,
            userAperture: userAperture > 0 ? userAperture : fallback.userAperture,
            selectedZoom: selectedZoom > 0 ? selectedZoom : fallback.selectedZoom
        )
    }

    static func save(
        iso: Double,
        compensation: Double,
        priority: PriorityMode,
        userShutter: Double,
        userAperture: Double,
        selectedZoom: Double
    ) {
        defaults.set(iso, forKey: Key.iso)
        defaults.set(compensation, forKey: Key.compensation)
        defaults.set(priority == .aperture ? "aperture" : "shutter", forKey: Key.priority)
        defaults.set(userShutter, forKey: Key.userShutter)
        defaults.set(userAperture, forKey: Key.userAperture)
        defaults.set(selectedZoom, forKey: Key.selectedZoom)
    }

    /// `nil` means not probed yet on this install.
    static func loadAvailableZooms() -> [Double]? {
        defaults.array(forKey: Key.availableZooms) as? [Double]
    }

    static func saveAvailableZooms(_ zooms: [Double]) {
        defaults.set(zooms, forKey: Key.availableZooms)
    }
}
