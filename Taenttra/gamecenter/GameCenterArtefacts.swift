//
//  GameCenterArtefacts.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

/// 🔹 Verwaltung des Artefakt-Highscores über Game Center (ohne UI)
struct GCArtefacts {

    /// 🏆 Leaderboard: gesammelte Artefakte (Lifetime)
    static let leaderboardID = "artefacts_collected"

    /// Reicht den aktuellen Artefakt-Stand bei Game Center ein
    static func submit(_ value: Int) {
        guard value >= 0 else {
            print("⚠️ GCArtefacts: Wert darf nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: value,
            leaderboardID: leaderboardID
        )
    }
}
