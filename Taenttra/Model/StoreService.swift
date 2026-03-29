//
//  StoreService.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import StoreKit
import Combine

@MainActor
final class StoreService: ObservableObject {

    static let shared = StoreService()

    @Published var products: [Product] = []

    func loadProducts(ids: [String]) async {
        do {
            products = try await Product.products(for: ids)
        } catch {
            print("❌ Failed to load products:", error)
        }
    }

    func purchase(product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return true
                case .unverified:
                    return false
                }

            case .userCancelled:
                return false

            default:
                return false
            }

        } catch {
            print("❌ Purchase failed:", error)
            return false
        }
    }
}
