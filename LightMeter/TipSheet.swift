import StoreKit
import SwiftUI

struct TipSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = TipStore()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.07, blue: 0.06).ignoresSafeArea()

                Group {
                    switch store.purchasePhase {
                    case .thanks:
                        thanksContent
                    default:
                        tipContent
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MeterTheme.cream.opacity(0.85))
                    }
                    .accessibilityLabel(Text("sheet.cancel"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            await store.loadProducts()
        }
    }

    private var tipContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("tip.headline")
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(MeterTheme.cream)
                .fixedSize(horizontal: false, vertical: true)

            Text("tip.subtitle")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(MeterTheme.muted)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)

            tipDivider
                .padding(.vertical, 22)

            Group {
                switch store.loadState {
                case .idle, .loading:
                    ProgressView()
                        .tint(MeterTheme.amber)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                case .failed:
                    VStack(spacing: 14) {
                        Text("tip.error.load")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(MeterTheme.muted)
                            .multilineTextAlignment(.center)
                        Button {
                            Task { await store.loadProducts() }
                        } label: {
                            Text("tip.retry")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(MeterTheme.ink)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule(style: .continuous).fill(MeterTheme.amber)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                case .ready:
                    VStack(spacing: 10) {
                        ForEach(store.products, id: \.id) { product in
                            tipRow(product)
                        }
                    }
                }
            }

            if let error = store.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(MeterTheme.danger)
                    .padding(.top, 12)
            }

            Spacer(minLength: 20)

            Button {
                Task { await store.purchaseSelected() }
            } label: {
                ZStack {
                    if store.purchasePhase == .purchasing {
                        ProgressView()
                            .tint(MeterTheme.ink)
                    } else {
                        Text("tip.confirm")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(MeterTheme.ink)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(store.canConfirm ? MeterTheme.amber : MeterTheme.amber.opacity(0.35))
                )
            }
            .buttonStyle(.plain)
            .disabled(!store.canConfirm)

            Text("tip.footer")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(MeterTheme.muted.opacity(0.85))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    private var thanksContent: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image(systemName: "heart.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(MeterTheme.amber)
            Text("tip.thanks.title")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(MeterTheme.cream)
            Text("tip.thanks.subtitle")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(MeterTheme.muted)
                .multilineTextAlignment(.center)
            Spacer(minLength: 24)
            Button {
                store.resetAfterThanks()
                dismiss()
            } label: {
                Text("tip.thanks.done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(MeterTheme.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(MeterTheme.amber)
                    )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 22)
    }

    private var tipDivider: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(MeterTheme.amber.opacity(0.45))
                .frame(height: 1)
            Circle()
                .fill(MeterTheme.amber)
                .frame(width: 6, height: 6)
            Rectangle()
                .fill(MeterTheme.amber.opacity(0.45))
                .frame(height: 1)
        }
    }

    private func tipRow(_ product: Product) -> some View {
        let selected = product.id == store.selectedProductID
        let labelKey = tipLabelKey(for: product.id)
        return Button {
            store.select(product.id)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(selected ? MeterTheme.amber : MeterTheme.cream.opacity(0.45), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle()
                            .fill(MeterTheme.amber)
                            .frame(width: 10, height: 10)
                    }
                }

                Text(labelKey)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(selected ? MeterTheme.ink : MeterTheme.cream)

                Spacer(minLength: 8)

                Text(product.displayPrice)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(selected ? MeterTheme.ink : MeterTheme.cream)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? MeterTheme.amber : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                selected ? MeterTheme.amber : Color.white.opacity(0.12),
                                lineWidth: selected ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(store.purchasePhase == .purchasing)
    }

    private func tipLabelKey(for productID: String) -> LocalizedStringKey {
        switch productID {
        case TipProductID.tier1: "tip.tier1"
        case TipProductID.tier2: "tip.tier2"
        case TipProductID.tier3: "tip.tier3"
        default: "tip.tier1"
        }
    }
}

#Preview {
    TipSheet()
}
