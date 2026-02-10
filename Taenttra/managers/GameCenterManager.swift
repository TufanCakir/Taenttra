//
//  GameCenterManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Combine
import Foundation
import GameKit

@MainActor
final class GameCenterManager: NSObject, ObservableObject {

    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated = false
    @Published private(set) var playerName: String = "Not logged in"

    private var didAuthenticate = false

    private override init() {}

    // MARK: - Authentication (SAFE)
    func authenticateIfNeeded() {
        guard !didAuthenticate else { return }
        didAuthenticate = true

        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            guard let self else { return }

            if let error {
                print("❌ Game Center Error:", error.localizedDescription)
            }

            // 🔐 WICHTIG: Login-UI MUSS präsentiert werden
            if let vc {
                self.present(vc)
                return
            }

            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                self.playerName = GKLocalPlayer.local.displayName
                print("🎮 Game Center logged in as:", self.playerName)
            } else {
                self.isAuthenticated = false
                print("⚠️ Game Center not authenticated")
            }
        }
    }

    // MARK: - UI Präsentation (UIKit-Bridge)
    private func present(_ vc: UIViewController) {
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene,
            let root = scene.windows.first?.rootViewController
        else {
            print("❌ Kein RootViewController für Game Center UI")
            return
        }

        root.present(vc, animated: true)
    }

    // MARK: - Score Submission
    func submit(score: Int, leaderboardID: String) {
        guard isAuthenticated else {
            print("⚠️ Score nicht gesendet – nicht eingeloggt")
            return
        }

        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error {
                print("❌ Score Error:", error.localizedDescription)
            } else {
                print("🏆 Score gesendet:", leaderboardID, score)
            }
        }
    }
}
