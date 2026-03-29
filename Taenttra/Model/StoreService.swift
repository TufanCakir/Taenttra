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
    private enum StoreError: LocalizedError {
        case unverifiedTransaction
        case pendingPurchase
        case unknownPurchaseResult

        var errorDescription: String? {
            switch self {
            case .unverifiedTransaction:
                return "The transaction could not be verified."
            case .pendingPurchase:
                return "The purchase is still pending."
            case .unknownPurchaseResult:
                return "The purchase did not complete."
            }
        }
    }

    static let shared = StoreService()

    @Published var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchaseInProgress = false
    @Published private(set) var lastErrorMessage: String?

    private var loadedProductIDs: Set<String> = []

    private init() {}

    func loadProducts(ids: [String]) async {
        let uniqueIDs = Set(ids)
        guard !uniqueIDs.isEmpty else {
            products = []
            loadedProductIDs = []
            lastErrorMessage = nil
            return
        }

        guard uniqueIDs != loadedProductIDs else { return }

        isLoadingProducts = true
        lastErrorMessage = nil

        do {
            let fetchedProducts = try await Product.products(for: Array(uniqueIDs))
            products = fetchedProducts.sorted { $0.id < $1.id }
            loadedProductIDs = uniqueIDs
        } catch {
            lastErrorMessage = error.localizedDescription
        }

        isLoadingProducts = false
    }

    func product(for id: String?) -> Product? {
        guard let id else { return nil }
        return products.first(where: { $0.id == id })
    }

    func clearError() {
        lastErrorMessage = nil
    }

    func purchase(product: Product) async -> Bool {
        purchaseInProgress = true
        lastErrorMessage = nil

        defer {
            purchaseInProgress = false
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return true
                case .unverified:
                    lastErrorMessage = StoreError.unverifiedTransaction.localizedDescription
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                lastErrorMessage = StoreError.pendingPurchase.localizedDescription
                return false
            default:
                lastErrorMessage = StoreError.unknownPurchaseResult.localizedDescription
                return false
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }
}
