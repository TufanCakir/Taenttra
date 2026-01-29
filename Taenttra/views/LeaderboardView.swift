//
//  LeaderboardView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import GameKit
import SwiftUI

struct LeaderboardView: View {

    @EnvironmentObject var gameState: GameState

    @ObservedObject private var gameCenter = GameCenterManager.shared

    var body: some View {
        ZStack {

            // 🌌 Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                header

                Spacer()

                fightersStage  // 🔥 NEU

                Spacer()

                if gameCenter.isAuthenticated {
                    leaderboardButton
                } else {
                    notAuthenticatedState
                }
            }
            .padding()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("GLOBAL RANKING")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .tracking(1.2)

            Text("Who is the strongest fighter?")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var playerCharacter: Character {
        Character(
            key: "kenji",
            combatSpritePrefix: nil,
            isLocked: false,
            skinId: gameState.wallet?.equippedSkin
        )
    }

    private var rivalCharacter: Character {
        Character(
            key: "kenji",
            combatSpritePrefix: nil,
            isLocked: false,
            skinId: "kenji_red_skin"
        )
    }

    // MARK: - Fighters Stage
    private var fightersStage: some View {
        HStack(alignment: .bottom, spacing: 24) {

            Image(playerCharacter.imageNameSafe(for: .idle))
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .opacity(0.85)
                .shadow(color: .black.opacity(0.6), radius: 20)

            Image(rivalCharacter.imageNameSafe(for: .idle))
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .opacity(0.85)
                .shadow(color: .black.opacity(0.6), radius: 20)
        }
    }

    // MARK: - Leaderboard Button

    private var leaderboardButton: some View {
        Button {
            GameCenterManager.shared.showLeaderboard()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.headline)

                Text("OPEN LEADERBOARD")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(1)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Color.mint)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Not Authenticated

    private var notAuthenticatedState: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.6))

            Text("Game Center not available")
                .font(.headline)
                .foregroundColor(.white)

            Text("Sign in to Game Center to see rankings")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    LeaderboardView()
}
