//
//  VictoryRewards.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Foundation

struct VictoryRewards: Codable, Equatable {

    var coins: Int
    var crystals: Int

    static let zero = VictoryRewards(
        coins: 0,
        crystals: 0
    )

    // 🔥 Komfort: Addieren von Rewards
    mutating func add(coins: Int = 0, crystals: Int = 0) {
        self.coins += coins
        self.crystals += crystals
    }

    // 🔥 Komfort: Kombinieren zweier Rewards
    static func += (lhs: inout VictoryRewards, rhs: VictoryRewards) {
        lhs.coins += rhs.coins
        lhs.crystals += rhs.crystals
    }
}
