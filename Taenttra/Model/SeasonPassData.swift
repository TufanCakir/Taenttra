//
//  SeasonPassData.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import Foundation
import SwiftUI

struct SeasonPassCatalog: Codable {
    let currentSeasonID: String
    let seasons: [SeasonPass]

    var currentSeason: SeasonPass? {
        seasons.first { $0.id == currentSeasonID }
    }
}

struct SeasonPass: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let accentHex: String
    let xpPerTier: Int
    let fightWinXP: Int
    let summonPullXP: Int
    let tiers: [SeasonPassTier]

    var accentColor: Color {
        Color(hex: accentHex)
    }
}

struct SeasonPassTier: Codable, Identifiable {
    let id: String
    let level: Int
    let title: String
    let rewardText: String
    let reward: ProgressReward

    var tierID: String { id }
}

struct ProgressReward: Codable {
    let type: ProgressRewardType
    let amount: Int
    let themeID: String?
}

enum ProgressRewardType: String, Codable {
    case coins
    case crystals
    case shards
    case pity
    case backgroundTheme = "background_theme"
}

enum SeasonPassLoader {
    static func load() -> SeasonPassCatalog {
        guard
            let url = Bundle.main.url(forResource: "season_passes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(SeasonPassCatalog.self, from: data)
        else {
            return SeasonPassCatalog(currentSeasonID: "season_1", seasons: [])
        }

        return decoded
    }
}

enum ProgressRewardService {
    static func apply(_ reward: ProgressReward, to wallet: PlayerWallet) {
        switch reward.type {
        case .coins:
            wallet.coins += reward.amount
        case .crystals:
            wallet.crystals += reward.amount
        case .shards:
            wallet.shards += reward.amount
        case .pity:
            wallet.summonPity = min(wallet.summonPity + reward.amount, 19)
        case .backgroundTheme:
            guard let themeID = reward.themeID else { return }
            BackgroundThemeService.unlock(themeID: themeID, wallet: wallet)
        }
    }
}
