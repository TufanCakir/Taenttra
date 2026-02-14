//
//  PlayerData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftData

@Model
final class PlayerData {

    var coins: Int
    var gems: Int
    var currentWorld: String
    var unlockedWorlds: [String]

    init(
        coins: Int = 0,
        gems: Int = 0,
        currentWorld: String = "normal",
        unlockedWorlds: [String] = ["normal"]
    ) {
        self.coins = coins
        self.gems = gems
        self.currentWorld = currentWorld
        self.unlockedWorlds = unlockedWorlds
    }
}
