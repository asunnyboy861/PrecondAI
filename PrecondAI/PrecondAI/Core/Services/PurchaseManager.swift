import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    var isPremium = false
    var monthlyProduct: Product?
    var yearlyProduct: Product?
    var products: [Product] = []

    private let monthlyID = "com.zzoutuo.PrecondAI.monthly"
    private let yearlyID = "com.zzoutuo.PrecondAI.yearly"

    func loadProducts() async {
        do {
            products = try await Product.products(for: [monthlyID, yearlyID])
            monthlyProduct = products.first { $0.id == monthlyID }
            yearlyProduct = products.first { $0.id == yearlyID }
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
        do {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == monthlyID || transaction.productID == yearlyID {
                        isPremium = true
                    }
                    await transaction.finish()
                }
            }
        } catch {}
    }

    func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlyID || transaction.productID == yearlyID {
                    isPremium = true
                }
                await transaction.finish()
            }
        }
    }
}
