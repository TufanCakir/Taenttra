//
//  WalletStore.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI
import Combine

final class WalletStore: ObservableObject {

    @Published private(set) var coins: Int = 0
    @Published private(set) var crystals: Int = 0

    // MARK: - Add
    func add(_ amount: Int, type: CurrencyType) {
        guard amount > 0 else { return }

        switch type {
        case .coins:
            coins += amount
        case .crystals:
            crystals += amount
        }
    }

    // MARK: - Spend
    func spend(_ amount: Int, type: CurrencyType) -> Bool {
        guard amount > 0 else { return false }

        switch type {
        case .coins:
            guard coins >= amount else { return false }
            coins -= amount

        case .crystals:
            guard crystals >= amount else { return false }
            crystals -= amount
        }

        return true
    }

    // MARK: - Reset (Debug / New Run)
    func reset() {
        coins = 0
        crystals = 0
    }
}
