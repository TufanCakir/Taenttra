//
//  CrystalStore.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Combine
import Foundation
import StoreKit

enum PurchaseError: Error {
    case failedVerification
}

@MainActor
final class CrystalStore: ObservableObject {

    static let shared = CrystalStore()

    @Published var products: [Product] = []
    @Published var isLoading = false

    private init() {}

    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await Product.products(for: [
                "crystals_small_100",
                "crystals_medium_500",
                "crystals_large_1200",
            ])

            // 🔥 SORTIEREN: klein → groß
            products = loaded.sorted {
                crystalsForProduct(id: $0.id) < crystalsForProduct(id: $1.id)
            }

        } catch {
            print("❌ Failed to load products:", error)
        }
    }

    // MARK: - Purchase
    func buy(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await handle(transaction)
                await transaction.finish()

            case .userCancelled:
                print("🟡 Purchase cancelled")

            case .pending:
                print("🟠 Purchase pending")

            default:
                break
            }
        } catch {
            print("❌ Purchase failed:", error)
        }
    }

    // MARK: - Restore Purchases
    func restore() async {
        print("🔄 Restoring purchases...")

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                await handle(transaction)
                print("♻️ Restored:", transaction.productID)

            case .unverified(_, let error):
                print("❌ Unverified transaction:", error)
            }
        }
    }

    // MARK: - Handle Transaction
    private func handle(_ transaction: Transaction) async {
        let crystals = crystalsForProduct(id: transaction.productID)
        CrystalManager.shared.addCrystals(crystals)

        print("💎 Added \(crystals) crystals")
    }

    // MARK: - Verification
    private func checkVerified<T>(
        _ result: VerificationResult<T>
    ) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw PurchaseError.failedVerification
        }
    }

    // MARK: - Mapping
    private func crystalsForProduct(id: String) -> Int {
        switch id {
        case "crystals_small_100": return 100
        case "crystals_medium_500": return 500
        case "crystals_large_1200": return 1200
        default: return 0
        }
    }
}
