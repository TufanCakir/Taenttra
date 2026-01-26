//
//  RewardStore.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftData
import SwiftUI
import Combine

@MainActor
final class RewardStore: ObservableObject {

    @Published var wallet: PlayerWallet

    init(context: ModelContext) {
        let fetch = FetchDescriptor<PlayerWallet>()
        if let existing = try? context.fetch(fetch).first {
            self.wallet = existing
        } else {
            let newWallet = PlayerWallet()
            context.insert(newWallet)
            try? context.save()
            self.wallet = newWallet
        }
    }

    func add(coins: Int, crystals: Int) {
        wallet.coins += coins
        wallet.crystals += crystals
    }
}


