//
//  GameCenterPlaytime.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

/// ⏱️ Reicht die gesamte Spielzeit (in Minuten) bei Game Center ein – UI-frei
struct GCPlaytime {

    static let leaderboardID = "playtime_minutes"

    static func submit(_ minutes: Int) {
        guard minutes >= 0 else {
            print("⚠️ GCPlaytime: Minuten dürfen nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: minutes,
            leaderboardID: leaderboardID
        )
    }
}
