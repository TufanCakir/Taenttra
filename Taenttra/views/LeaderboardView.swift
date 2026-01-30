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
        ZStack(alignment: .topLeading) {

            // 🌌 Background
            Color.black.ignoresSafeArea()

            // ⬅️ BACK BUTTON (GAME STYLE)
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            VStack(spacing: 24) {

                header

                Spacer()

                fightersStage

                Spacer()

                if gameCenter.isAuthenticated {
                    leaderboardButton
                } else {
                    notAuthenticatedState
                }
            }
            .padding()
            .padding(.top, 48)  // 🔥 Platz für BackButton
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("GLOBAL CONFEDERATION")
                .font(.system(size: 14, weight: .heavy))
                .tracking(2)
                .foregroundStyle(.cyan.opacity(0.85))

            Text("WORLD RANKING")
                .font(.system(size: 28, weight: .heavy))
                .tracking(2)
                .foregroundStyle(.white)

            Text("Wer ist der stärkste Kämpfer?")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
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
        ZStack {

            // 🔥 Floor Glow
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.08),
                    .clear,
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 120)
            .offset(y: 40)

            HStack(alignment: .bottom, spacing: 32) {

                fighterSlot(
                    image: playerCharacter.imageNameSafe(for: .idle),
                    name: "YOU",
                    color: .cyan
                )

                Text("VS")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundStyle(.red)
                    .shadow(color: .red.opacity(0.8), radius: 12)

                fighterSlot(
                    image: rivalCharacter.imageNameSafe(for: .idle),
                    name: "RIVAL",
                    color: .red
                )
            }
        }
    }

    private func fighterSlot(
        image: String,
        name: String,
        color: Color
    ) -> some View {
        VStack(spacing: 6) {

            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 110)
                .shadow(color: color.opacity(0.6), radius: 20)

            Text(name)
                .font(.caption.bold())
                .tracking(1)
                .foregroundStyle(color)
        }
    }

    // MARK: - Leaderboard Button

    private var leaderboardButton: some View {
        Button {
            GameCenterManager.shared.showLeaderboard()
        } label: {
            Text("ENTER WORLD RANKING")
                .font(.system(size: 16, weight: .heavy))
                .tracking(1)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .cornerRadius(12)
                .shadow(color: .cyan.opacity(0.7), radius: 18)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Not Authenticated
    private var notAuthenticatedState: some View {
        VStack(spacing: 12) {

            Text("GAME CENTER OFFLINE")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Text("Melde dich an, um dich mit anderen Kämpfern zu messen.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    LeaderboardView()
}
