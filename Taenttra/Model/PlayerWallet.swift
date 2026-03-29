//
//  PlayerWallet.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftData

@Model
final class PlayerWallet {

    var coins: Int = 0
    var crystals: Int = 0
    var shards: Int = 0

    var ownedSkins: [String] = []
    var equippedSkin: String? = nil
    var xp: Int = 0
    var level: Int = 1
    var unlockedCharacters: [String] = ["kenji"]

    init(
        coins: Int = 0,
        crystals: Int = 0,
        shards: Int = 0,
        ownedSkins: [String] = [],
        equippedSkin: String? = nil,
        xp: Int = 0,
        level: Int = 1,
        unlockedCharacters: [String] = ["kenji"]
    ) {
        self.coins = coins
        self.crystals = crystals
        self.shards = shards
        self.ownedSkins = ownedSkins
        self.equippedSkin = equippedSkin
        self.xp = xp
        self.level = level
        self.unlockedCharacters = unlockedCharacters
    }
}
