//
//  GameCenterKills.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

/// 🔹 Reicht die Gesamtzahl der besiegten Gegner (Kills) bei Game Center ein – ohne UI
struct GCKills {

    static let leaderboardID = "total_kills"

    /// Reicht einen gültigen Score bei Game Center ein
    static func submit(_ value: Int) {
        guard value >= 0 else {
            print("⚠️ GCKills: Score darf nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: value,
            leaderboardID: leaderboardID
        )
    }
}
