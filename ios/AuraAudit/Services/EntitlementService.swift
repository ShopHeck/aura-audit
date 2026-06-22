import Foundation
import StoreKit

@MainActor
final class EntitlementService: ObservableObject {
    @Published private(set) var isPremium = false

    let premiumProductId = "app.auraaudit.premium.lifetime"

    func refreshEntitlements() async {
        var premium = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == premiumProductId {
                premium = true
            }
        }
        isPremium = premium
    }

    func purchasePremium() async throws {
        let products = try await Product.products(for: [premiumProductId])
        guard let product = products.first else { return }
        let result = try await product.purchase()

        if case .success(let verification) = result, case .verified(let transaction) = verification {
            await transaction.finish()
            await refreshEntitlements()
        }
    }
}
