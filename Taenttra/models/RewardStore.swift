//
//  RewardStore.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftData
import SwiftUI

@MainActor
final class RewardStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func wallet() -> PlayerWallet {
        let fetch = FetchDescriptor<PlayerWallet>()

        if let existing = try? context.fetch(fetch).first {
            return existing
        }

        let newWallet = PlayerWallet()
        context.insert(newWallet)
        return newWallet
    }

    func add(coins: Int, crystals: Int) {
        let wallet = wallet()
        wallet.coins += coins
        wallet.crystals += crystals
    }
}
