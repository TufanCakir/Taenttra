//
//  GameCenterManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import Combine
import GameKit
import SwiftUI

@MainActor
final class GameCenterManager: NSObject, ObservableObject {

    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated = false

    private let leaderboardID = "global_rank"

    private override init() {
        super.init()
    }

    // MARK: - Authentication

    func authenticate() {
        let player = GKLocalPlayer.local

        player.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }

            if let viewController {
                self.present(viewController)
                return
            }

            if player.isAuthenticated {
                self.isAuthenticated = true
                print("✅ Game Center authenticated as \(player.displayName)")
            } else {
                self.isAuthenticated = false

                if let error {
                    print(
                        "❌ Game Center authentication failed: \(error.localizedDescription)"
                    )
                } else {
                    print(
                        "ℹ️ Game Center authentication cancelled or unavailable"
                    )
                }
            }
        }
    }

    // MARK: - Submit Score

    func submitScore(_ score: Int) async {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("⚠️ Score submission skipped – player not authenticated")
            return
        }

        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboardID]
            )
            print("🏆 Score submitted: \(score)")
        } catch {
            print("❌ Failed to submit score: \(error.localizedDescription)")
        }
    }

    // MARK: - Show Leaderboard

    func showLeaderboard() {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("⚠️ Tried to open leaderboard without authentication")
            return
        }

        let vc = GKGameCenterViewController(
            leaderboardID: leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )

        vc.gameCenterDelegate = self
        present(vc)
    }

    // MARK: - Presentation Helper

    private func present(_ viewController: UIViewController) {
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene,
            let root = scene.keyWindow?.rootViewController
        else {
            print("❌ Failed to present Game Center UI")
            return
        }

        root.present(viewController, animated: true)
    }
}

// MARK: - Game Center Delegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
        gameCenterViewController.dismiss(animated: true)
    }
}
