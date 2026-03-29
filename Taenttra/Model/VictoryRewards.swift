//
//  VictoryRewards.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

struct VictoryRewards: Codable, Equatable {

    var coins: Int
    var crystals: Int
    var shards: Int  

    static let zero = VictoryRewards(
        coins: 0,
        crystals: 0,
        shards: 0
    )

    // 🔥 Komfort: Addieren von Rewards
    mutating func add(
        coins: Int = 0,
        crystals: Int = 0,
        shards: Int = 0
    ) {
        self.coins += coins
        self.crystals += crystals
        self.shards += shards
    }

    // 🔥 Komfort: Kombinieren zweier Rewards
    static func += (lhs: inout VictoryRewards, rhs: VictoryRewards) {
        lhs.coins += rhs.coins
        lhs.crystals += rhs.crystals
        lhs.shards += rhs.shards
    }
}
