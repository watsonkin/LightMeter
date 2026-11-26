import SwiftUI

struct ISOPickerSheet: View {
    let onConfirm: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selected: Double
    @State private var manualText: String
    @State private var manualError = false

    init(iso: Double, onConfirm: @escaping (Double) -> Void) {
        self.onConfirm = onConfirm
        let nearest = ExposureMath.nearest(iso, in: ExposureMath.isoStops)
        _selected = State(initialValue: nearest)
        _manualText = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("sheet.iso.title")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                Picker("ISO", selection: $selected) {
                    ForEach(ExposureMath.isoStops, id: \.self) { value in
                        Text("\(Int(value))").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)
                .onChange(of: selected) { _, _ in
                    manualText = ""
                    manualError = false
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("sheet.iso.manual")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(MeterTheme.muted)
                    TextField("100", text: $manualText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: manualText) { _, _ in
                            manualError = false
                        }
                    if manualError {
                        Text("sheet.iso.manual_error")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(MeterTheme.danger)
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    Button("sheet.cancel") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.1))
                        )

                    Button("sheet.confirm") { confirm() }
                        .fontWeight(.semibold)
                        .foregroundStyle(MeterTheme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(MeterTheme.amber)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color(red: 0.12, green: 0.11, blue: 0.10))
            .foregroundStyle(MeterTheme.cream)
        }
        .preferredColorScheme(.dark)
    }

    private func confirm() {
        let trimmed = manualText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            onConfirm(selected)
            dismiss()
            return
        }
        guard let value = Double(trimmed), value >= 1, value <= 102400 else {
            manualError = true
            return
        }
        onConfirm(value)
        dismiss()
    }
}

struct CompensationPickerSheet: View {
    let onConfirm: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int

    private var stops: [Double] { ExposureMath.compensationStops }

    init(value: Double, onConfirm: @escaping (Double) -> Void) {
        self.onConfirm = onConfirm
        let nearest = ExposureMath.nearest(value, in: ExposureMath.compensationStops)
        let index = ExposureMath.compensationStops.firstIndex(of: nearest)
            ?? ExposureMath.compensationStops.firstIndex(where: { abs($0 - nearest) < 0.01 })
            ?? 6
        _selectedIndex = State(initialValue: index)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("sheet.ec.title")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(ExposureMath.formatCompensation(stops[selectedIndex]))
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(MeterTheme.amber)

                Text("sheet.ec.hint")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(MeterTheme.muted)
                    .multilineTextAlignment(.center)

                Picker("EC", selection: $selectedIndex) {
                    ForEach(stops.indices, id: \.self) { index in
                        Text(ExposureMath.formatCompensation(stops[index])).tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    Button("sheet.cancel") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.1))
                        )

                    Button("sheet.confirm") {
                        onConfirm(stops[selectedIndex])
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(MeterTheme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(MeterTheme.amber)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color(red: 0.12, green: 0.11, blue: 0.10))
            .foregroundStyle(MeterTheme.cream)
        }
        .preferredColorScheme(.dark)
    }
}

struct ShutterPickerSheet: View {
    let onConfirm: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selected: Double

    init(shutter: Double, onConfirm: @escaping (Double) -> Void) {
        self.onConfirm = onConfirm
        _selected = State(initialValue: ExposureMath.nearest(shutter, in: ExposureMath.shutterStops))
    }

    var body: some View {
        valuePickerSheet(
            titleKey: "sheet.shutter.title",
            hintKey: "sheet.shutter.hint",
            selection: $selected,
            values: ExposureMath.shutterStops,
            label: ExposureMath.formatShutter
        ) {
            onConfirm(selected)
            dismiss()
        } onCancel: {
            dismiss()
        }
    }
}

struct AperturePickerSheet: View {
    let onConfirm: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selected: Double

    init(aperture: Double, onConfirm: @escaping (Double) -> Void) {
        self.onConfirm = onConfirm
        _selected = State(initialValue: ExposureMath.nearest(aperture, in: ExposureMath.apertureStops))
    }

    var body: some View {
        valuePickerSheet(
            titleKey: "sheet.aperture.title",
            hintKey: "sheet.aperture.hint",
            selection: $selected,
            values: ExposureMath.apertureStops,
            label: ExposureMath.formatAperture
        ) {
            onConfirm(selected)
            dismiss()
        } onCancel: {
            dismiss()
        }
    }
}

private func valuePickerSheet(
    titleKey: LocalizedStringKey,
    hintKey: LocalizedStringKey,
    selection: Binding<Double>,
    values: [Double],
    label: @escaping (Double) -> String,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
) -> some View {
    NavigationStack {
        VStack(spacing: 16) {
            Text(titleKey)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(label(selection.wrappedValue))
                .font(.system(size: 40, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(MeterTheme.amber)

            Text(hintKey)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(MeterTheme.muted)
                .multilineTextAlignment(.center)

            Picker("", selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text(label(value)).tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 140)

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                Button("sheet.cancel", action: onCancel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                    )

                Button("sheet.confirm", action: onConfirm)
                    .fontWeight(.semibold)
                    .foregroundStyle(MeterTheme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(MeterTheme.amber)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color(red: 0.12, green: 0.11, blue: 0.10))
        .foregroundStyle(MeterTheme.cream)
    }
    .preferredColorScheme(.dark)
}
