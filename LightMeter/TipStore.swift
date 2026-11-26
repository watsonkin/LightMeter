import Foundation
import StoreKit

enum TipProductID {
    static let tier1 = "com.watstudio.LightMeter.tip.tier1"
    static let tier2 = "com.watstudio.LightMeter.tip.tier2"
    static let tier3 = "com.watstudio.LightMeter.tip.tier3"

    static let all: [String] = [tier1, tier2, tier3]

    static func tierIndex(for productID: String) -> Int? {
        all.firstIndex(of: productID)
    }
}

enum TipLoadState: Equatable {
    case idle
    case loading
    case ready
    case failed
}

enum TipPurchasePhase: Equatable {
    case idle
    case purchasing
    case thanks
}

@MainActor
final class TipStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var loadState: TipLoadState = .idle
    @Published private(set) var purchasePhase: TipPurchasePhase = .idle
    @Published var selectedProductID: String = TipProductID.tier2
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await listenForTransactions() }
    }

    deinit {
        updatesTask?.cancel()
    }

    var selectedProduct: Product? {
        products.first { $0.id == selectedProductID }
    }

    var canConfirm: Bool {
        loadState == .ready
            && selectedProduct != nil
            && purchasePhase == .idle
    }

    func loadProducts() async {
        loadState = .loading
        errorMessage = nil
        do {
            let fetched = try await Product.products(for: TipProductID.all)
            let ordered = TipProductID.all.compactMap { id in
                fetched.first { $0.id == id }
            }
            products = ordered
            if ordered.isEmpty {
                loadState = .failed
            } else {
                if !ordered.contains(where: { $0.id == selectedProductID }) {
                    selectedProductID = TipProductID.tier2
                    if !ordered.contains(where: { $0.id == selectedProductID }) {
                        selectedProductID = ordered[min(1, ordered.count - 1)].id
                    }
                }
                loadState = .ready
            }
        } catch {
            products = []
            loadState = .failed
        }
    }

    func select(_ productID: String) {
        guard purchasePhase == .idle else { return }
        selectedProductID = productID
    }

    func purchaseSelected() async {
        guard let product = selectedProduct, canConfirm else { return }
        purchasePhase = .purchasing
        errorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasePhase = .thanks
            case .userCancelled:
                purchasePhase = .idle
            case .pending:
                purchasePhase = .idle
            @unknown default:
                purchasePhase = .idle
            }
        } catch {
            purchasePhase = .idle
            errorMessage = String(localized: "tip.error.purchase")
        }
    }

    func resetAfterThanks() {
        purchasePhase = .idle
        selectedProductID = TipProductID.tier2
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update {
                await transaction.finish()
            }
        }
    }

    private enum StoreError: Error {
        case failedVerification
    }
}
