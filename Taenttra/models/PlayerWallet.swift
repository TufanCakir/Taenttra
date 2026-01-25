//
//  PlayerWallet.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftData

@Model
final class PlayerWallet {

    var coins: Int
    var crystals: Int
    var ownedSkins: [String]
    var equippedSkin: String?
    var xp: Int
    var level: Int
    var unlockedCharacters: [String]

    init(
        coins: Int = 0,
        crystals: Int = 0,
        ownedSkins: [String] = [],
        equippedSkin: String? = nil,
        xp: Int = 0,
        level: Int = 1,
        unlockedCharacters: [String] = []
    ) {
        self.coins = coins
        self.crystals = crystals
        self.ownedSkins = ownedSkins
        self.equippedSkin = equippedSkin
        self.xp = xp
        self.level = level
        self.unlockedCharacters = unlockedCharacters
    }
}
