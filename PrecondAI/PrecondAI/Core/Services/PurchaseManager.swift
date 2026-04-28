import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    var isPremium = false
    var monthlyProduct: Product?
    var yearlyProduct: Product?
    var lifetimeProduct: Product?
    var products: [Product] = []

    private let monthlyID = "com.zzoutuo.PrecondAI.monthly"
    private let yearlyID = "com.zzoutuo.PrecondAI.yearly"
    private let lifetimeID = "com.zzoutuo.PrecondAI.lifetime"

    func loadProducts() async {
        do {
            products = try await Product.products(for: [monthlyID, yearlyID, lifetimeID])
            monthlyProduct = products.first { $0.id == monthlyID }
            yearlyProduct = products.first { $0.id == yearlyID }
            lifetimeProduct = products.first { $0.id == lifetimeID }
        } catch {}
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .unverified:
                    return false
                case .verified(let transaction):
                    isPremium = true
                    await transaction.finish()
                    return true
                }
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlyID || transaction.productID == yearlyID || transaction.productID == lifetimeID {
                    isPremium = true
                }
                await transaction.finish()
            }
        }
    }

    func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlyID || transaction.productID == yearlyID || transaction.productID == lifetimeID {
                    isPremium = true
                }
                await transaction.finish()
            }
        }
    }
}
