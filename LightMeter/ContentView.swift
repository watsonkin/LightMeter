import SwiftUI

private enum ActiveSheet: Identifiable {
    case iso
    case compensation
    case shutter
    case aperture
    case tip

    var id: String {
        switch self {
        case .iso: "iso"
        case .compensation: "compensation"
        case .shutter: "shutter"
        case .aperture: "aperture"
        case .tip: "tip"
        }
    }
}

struct ContentView: View {
    @StateObject private var meter = CameraMeter()
    @State private var settings: ExposureSettings
    @State private var priority: PriorityMode
    @State private var compensation: Double
    /// Last values the user explicitly chose (never overwritten by calculation).
    @State private var userShutter: Double
    @State private var userAperture: Double
    @State private var selectedZoom: Double
    @State private var sheet: ActiveSheet?

    init() {
        let saved = MeterPreferences.load()
        _priority = State(initialValue: saved.priority)
        _compensation = State(initialValue: saved.compensation)
        _userShutter = State(initialValue: saved.userShutter)
        _userAperture = State(initialValue: saved.userAperture)
        _selectedZoom = State(initialValue: saved.selectedZoom)
        _settings = State(
            initialValue: ExposureSettings(
                iso: saved.iso,
                aperture: saved.userAperture,
                shutter: saved.userShutter
            )
        )
    }

    private var measuredEV: Double { meter.liveEV100 }
    private var effectiveEV: Double {
        ExposureMath.effectiveEV(measured: measuredEV, compensation: compensation)
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.07, blue: 0.06).ignoresSafeArea()

            CameraPreview(session: meter.session)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                if meter.permissionDenied {
                    Text("permission.camera_settings")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(MeterTheme.danger)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer(minLength: 0)
                if meter.showsZoomControls {
                    zoomBar
                        .padding(.bottom, 10)
                }
                bottomBar
            }
        }
        .task {
            // Restore user-chosen side, then fill the calculated side from live metering.
            applyUserChosenSide()
            await meter.start()
            syncZoomFromMeter()
            meter.setZoomFactor(selectedZoom)
            persist()
            recompute()
        }
        .onChange(of: meter.liveEV100) { _, _ in
            recompute()
        }
        .onChange(of: meter.availableZooms) { _, _ in
            syncZoomFromMeter()
            persist()
        }
        .onDisappear {
            meter.stop()
        }
        .sheet(item: $sheet) { item in
            switch item {
            case .iso:
                ISOPickerSheet(iso: settings.iso) { value in
                    settings.iso = value
                    persist()
                    recompute()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            case .compensation:
                CompensationPickerSheet(value: compensation) { value in
                    compensation = value
                    persist()
                    recompute()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            case .shutter:
                ShutterPickerSheet(shutter: userShutter) { value in
                    priority = .shutter
                    userShutter = value
                    settings.shutter = value
                    persist()
                    recompute()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            case .aperture:
                AperturePickerSheet(aperture: userAperture) { value in
                    priority = .aperture
                    userAperture = value
                    settings.aperture = value
                    persist()
                    recompute()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            case .tip:
                TipSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                sheet = .tip
            } label: {
                Image("Wordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22)
                    .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("tip.entry"))

            Spacer(minLength: 4)

            Text(ExposureMath.formatEVCompact(measuredEV))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(MeterTheme.amber)
                .lineLimit(1)

            Button {
                sheet = .compensation
            } label: {
                Text(ExposureMath.formatCompensation(compensation))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(MeterTheme.cream)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)

            Button {
                sheet = .iso
            } label: {
                HStack(spacing: 4) {
                    Text(ExposureMath.formatISO(settings.iso))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(MeterTheme.cream)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [.black.opacity(0.72), .black.opacity(0.25), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private var zoomBar: some View {
        HStack(spacing: 8) {
            ForEach(meter.availableZooms, id: \.self) { zoom in
                let isSelected = abs(zoom - selectedZoom) < 0.05
                Button {
                    selectedZoom = zoom
                    meter.setZoomFactor(zoom)
                    persist()
                } label: {
                    Text(ZoomCapability.format(zoom))
                        .font(.system(size: isSelected ? 15 : 13, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(isSelected ? MeterTheme.ink : MeterTheme.cream)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .background(
                            Circle()
                                .fill(isSelected ? MeterTheme.amber : Color.white.opacity(0.14))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.45))
        )
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            priorityButton(
                titleKey: "priority.shutter",
                value: ExposureMath.formatShutter(settings.shutter),
                isActive: priority == .shutter,
                isCalculated: priority == .aperture
            ) {
                sheet = .shutter
            }

            priorityButton(
                titleKey: "priority.aperture",
                value: ExposureMath.formatAperture(settings.aperture),
                isActive: priority == .aperture,
                isCalculated: priority == .shutter
            ) {
                sheet = .aperture
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.35), .black.opacity(0.78)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func priorityButton(
        titleKey: LocalizedStringKey,
        value: String,
        isActive: Bool,
        isCalculated: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Text(titleKey)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    if isCalculated {
                        Text("priority.calculated")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.white.opacity(0.14))
                            )
                    }
                }
                .foregroundStyle(isActive ? MeterTheme.ink : MeterTheme.muted)

                Text(value)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(isActive ? MeterTheme.ink : MeterTheme.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? MeterTheme.amber : Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                isActive ? MeterTheme.amber : Color.white.opacity(0.14),
                                lineWidth: isActive ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func applyUserChosenSide() {
        switch priority {
        case .shutter:
            settings.shutter = userShutter
        case .aperture:
            settings.aperture = userAperture
        }
    }

    private func recompute() {
        applyUserChosenSide()
        guard effectiveEV.isFinite else { return }
        settings = ExposureMath.resolve(ev100: effectiveEV, settings: settings, mode: priority)
    }

    private func syncZoomFromMeter() {
        selectedZoom = ZoomCapability.clamp(selectedZoom, to: meter.availableZooms)
    }

    private func persist() {
        MeterPreferences.save(
            iso: settings.iso,
            compensation: compensation,
            priority: priority,
            userShutter: userShutter,
            userAperture: userAperture,
            selectedZoom: selectedZoom
        )
    }
}

#Preview("中文") {
    ContentView()
        .environment(\.locale, .init(identifier: "zh-Hans"))
}

#Preview("English") {
    ContentView()
        .environment(\.locale, .init(identifier: "en"))
}
