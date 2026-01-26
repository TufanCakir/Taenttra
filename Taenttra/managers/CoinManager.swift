//
//  CoinManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import Combine
import SwiftUI

final class CoinManager: ObservableObject {

    static let shared = CoinManager()

    @Published private(set) var coins: Int = 0

    private let storageKey = "coins_storage"

    private init() {
        coins = UserDefaults.standard.integer(forKey: storageKey)
    }

    func add(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        save()
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, coins >= amount else { return false }
        coins -= amount
        save()
        return true
    }

    func reset() {
        coins = 0
        save()
    }

    private func save() {
        UserDefaults.standard.set(coins, forKey: storageKey)
    }
}
