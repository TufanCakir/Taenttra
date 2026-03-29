//
//  MissionData.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import Foundation
import SwiftUI

struct MissionCatalog: Codable {
    let seasonID: String
    let missions: [MissionDefinition]
}

struct MissionDefinition: Codable, Identifiable {
    let id: String
    let category: MissionCategory
    let title: String
    let detail: String
    let rewardText: String
    let accentHex: String
    let icon: String
    let requirement: MissionRequirement
    let rewards: [ProgressReward]

    var accentColor: Color {
        Color(hex: accentHex)
    }
}

enum MissionCategory: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case event

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .event:
            return "Event"
        }
    }

    var accentColor: Color {
        switch self {
        case .daily:
            return .cyan
        case .weekly:
            return .orange
        case .event:
            return .pink
        }
    }
}

struct MissionRequirement: Codable {
    let type: MissionRequirementType
    let target: Int
}

enum MissionRequirementType: String, Codable {
    case summonPulls = "summon_pulls"
    case dailyStreak = "daily_streak"
    case seasonXP = "season_xp"
    case fightWins = "fight_wins"
}

enum MissionLoader {
    static func load() -> MissionCatalog {
        guard
            let url = Bundle.main.url(forResource: "missions", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(MissionCatalog.self, from: data)
        else {
            return MissionCatalog(seasonID: "season_1", missions: [])
        }

        return decoded
    }
}

enum MissionProgressService {
    static func progress(
        for mission: MissionDefinition,
        wallet: PlayerWallet
    ) -> Int {
        switch mission.requirement.type {
        case .summonPulls:
            switch mission.category {
            case .daily:
                return wallet.dailySummonPullCount
            case .weekly:
                return wallet.weeklySummonPullCount
            case .event:
                return wallet.summonPullCount
            }
        case .dailyStreak:
            return wallet.dailyStreak
        case .seasonXP:
            return wallet.seasonPassXP
        case .fightWins:
            switch mission.category {
            case .daily:
                return wallet.dailyFightWins
            case .weekly:
                return wallet.weeklyFightWins
            case .event:
                return wallet.fightWins
            }
        }
    }

    static func claimKey(
        for mission: MissionDefinition,
        seasonID: String
    ) -> String {
        "\(seasonID):\(mission.id)"
    }
}

enum MissionResetService {
    static func syncResets(
        for wallet: PlayerWallet,
        catalog: MissionCatalog,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        resetDailyIfNeeded(for: wallet, catalog: catalog, now: now, calendar: calendar)
        resetWeeklyIfNeeded(for: wallet, catalog: catalog, now: now, calendar: calendar)
    }

    private static func resetDailyIfNeeded(
        for wallet: PlayerWallet,
        catalog: MissionCatalog,
        now: Date,
        calendar: Calendar
    ) {
        guard shouldResetDay(lastReset: wallet.lastMissionDailyResetAt, now: now, calendar: calendar) else {
            if wallet.lastMissionDailyResetAt == nil {
                wallet.lastMissionDailyResetAt = now
            }
            return
        }

        let dailyIDs = Set(
            catalog.missions
                .filter { $0.category == .daily }
                .map { MissionProgressService.claimKey(for: $0, seasonID: wallet.currentSeasonID) }
        )

        wallet.claimedMissionIDs.removeAll { dailyIDs.contains($0) }
        wallet.dailySummonPullCount = 0
        wallet.dailyFightWins = 0
        wallet.lastMissionDailyResetAt = now
    }

    private static func resetWeeklyIfNeeded(
        for wallet: PlayerWallet,
        catalog: MissionCatalog,
        now: Date,
        calendar: Calendar
    ) {
        guard shouldResetWeek(lastReset: wallet.lastMissionWeeklyResetAt, now: now, calendar: calendar) else {
            if wallet.lastMissionWeeklyResetAt == nil {
                wallet.lastMissionWeeklyResetAt = now
            }
            return
        }

        let weeklyIDs = Set(
            catalog.missions
                .filter { $0.category == .weekly }
                .map { MissionProgressService.claimKey(for: $0, seasonID: wallet.currentSeasonID) }
        )

        wallet.claimedMissionIDs.removeAll { weeklyIDs.contains($0) }
        wallet.weeklySummonPullCount = 0
        wallet.weeklyFightWins = 0
        wallet.lastMissionWeeklyResetAt = now
    }

    private static func shouldResetDay(
        lastReset: Date?,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        guard let lastReset else { return true }
        return !calendar.isDate(lastReset, inSameDayAs: now)
    }

    private static func shouldResetWeek(
        lastReset: Date?,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        guard let lastReset else { return true }
        let lastWeek = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: lastReset)
        let currentWeek = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: now)
        return lastWeek.weekOfYear != currentWeek.weekOfYear || lastWeek.yearForWeekOfYear != currentWeek.yearForWeekOfYear
    }
}
