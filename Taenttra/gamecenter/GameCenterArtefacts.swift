//
//  GameCenterArtefacts.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

/// 🔹 Verwaltung des Artefakt-Highscores über Game Center (ohne UI)
struct GCArtefacts {

    static let leaderboardID = "total_artefacts"

    /// Reicht den aktuellen Artefakt-Stand bei Game Center ein (nur wenn ≥ 0 und eingeloggt)
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
