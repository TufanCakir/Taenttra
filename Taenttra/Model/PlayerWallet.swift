//
//  PlayerWallet.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation
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
    var summonPity: Int = 0
    var summonPullCount: Int = 0
    var lastDailyClaimAt: Date? = nil
    var dailyStreak: Int = 0
    var claimedGiftPackIDs: [String] = []
    var seasonPassXP: Int = 0
    var claimedSeasonPassTiers: [Int] = []
    var claimedMissionIDs: [String] = []
    var currentSeasonID: String = "season_1"
    var claimedSeasonPassTierIDs: [String] = []
    var fightWins: Int = 0
    var dailySummonPullCount: Int = 0
    var weeklySummonPullCount: Int = 0
    var dailyFightWins: Int = 0
    var weeklyFightWins: Int = 0
    var lastMissionDailyResetAt: Date? = nil
    var lastMissionWeeklyResetAt: Date? = nil
    var ownedBackgroundThemeIDs: [String] = ["theme_default"]
    var selectedBackgroundThemeID: String = "theme_default"
    var ownedBattleCardIDs: [String] = []
    var deckSlotPayloads: [String] = []
    var selectedDeckSlotIndex: Int = 0

    init(
        coins: Int = 0,
        crystals: Int = 0,
        shards: Int = 0,
        ownedSkins: [String] = [],
        equippedSkin: String? = nil,
        xp: Int = 0,
        level: Int = 1,
        unlockedCharacters: [String] = ["kenji"],
        summonPity: Int = 0,
        summonPullCount: Int = 0,
        lastDailyClaimAt: Date? = nil,
        dailyStreak: Int = 0,
        claimedGiftPackIDs: [String] = [],
        seasonPassXP: Int = 0,
        claimedSeasonPassTiers: [Int] = [],
        claimedMissionIDs: [String] = [],
        currentSeasonID: String = "season_1",
        claimedSeasonPassTierIDs: [String] = [],
        fightWins: Int = 0,
        dailySummonPullCount: Int = 0,
        weeklySummonPullCount: Int = 0,
        dailyFightWins: Int = 0,
        weeklyFightWins: Int = 0,
        lastMissionDailyResetAt: Date? = nil,
        lastMissionWeeklyResetAt: Date? = nil,
        ownedBackgroundThemeIDs: [String] = ["theme_default"],
        selectedBackgroundThemeID: String = "theme_default",
        ownedBattleCardIDs: [String] = [],
        deckSlotPayloads: [String] = [],
        selectedDeckSlotIndex: Int = 0
    ) {
        self.coins = coins
        self.crystals = crystals
        self.shards = shards
        self.ownedSkins = ownedSkins
        self.equippedSkin = equippedSkin
        self.xp = xp
        self.level = level
        self.unlockedCharacters = unlockedCharacters
        self.summonPity = summonPity
        self.summonPullCount = summonPullCount
        self.lastDailyClaimAt = lastDailyClaimAt
        self.dailyStreak = dailyStreak
        self.claimedGiftPackIDs = claimedGiftPackIDs
        self.seasonPassXP = seasonPassXP
        self.claimedSeasonPassTiers = claimedSeasonPassTiers
        self.claimedMissionIDs = claimedMissionIDs
        self.currentSeasonID = currentSeasonID
        self.claimedSeasonPassTierIDs = claimedSeasonPassTierIDs
        self.fightWins = fightWins
        self.dailySummonPullCount = dailySummonPullCount
        self.weeklySummonPullCount = weeklySummonPullCount
        self.dailyFightWins = dailyFightWins
        self.weeklyFightWins = weeklyFightWins
        self.lastMissionDailyResetAt = lastMissionDailyResetAt
        self.lastMissionWeeklyResetAt = lastMissionWeeklyResetAt
        self.ownedBackgroundThemeIDs = ownedBackgroundThemeIDs
        self.selectedBackgroundThemeID = selectedBackgroundThemeID
        self.ownedBattleCardIDs = ownedBattleCardIDs
        self.deckSlotPayloads = deckSlotPayloads
        self.selectedDeckSlotIndex = selectedDeckSlotIndex
    }
}
