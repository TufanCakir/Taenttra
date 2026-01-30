//
//  GameHUDView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftUI

struct GameHUDView: View {

    @ObservedObject var viewModel: VersusViewModel
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 0) {

            ZStack {

                // 🌑 HUD BACKPLATE
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.65),
                        Color.clear,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 96)
                .ignoresSafeArea(edges: .top)

                // 🧱 CONTENT
                HStack(spacing: 12) {

                    // 🟦 PLAYER
                    SlantedPlayerHUD(
                        name: displayName(for: gameState.leftCharacter),
                        health: viewModel.leftHealth,
                        direction: .left
                    )

                    Spacer()

                    // ⏱ TIMER
                    timerView

                    Spacer()

                    // 🟥 ENEMY
                    SlantedPlayerHUD(
                        name: displayName(for: gameState.rightCharacter),
                        health: viewModel.rightHealth,
                        direction: .right
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            Spacer()
        }
    }

    // MARK: - Timer

    private var timerView: some View {
        Text("\(viewModel.timeRemaining)")
            .font(.system(size: 22, weight: .heavy, design: .monospaced))
            .foregroundColor(
                viewModel.timeRemaining <= 10 ? .red : .white
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        Capsule()
                            .stroke(
                                viewModel.timeRemaining <= 10
                                    ? Color.red.opacity(0.8)
                                    : Color.white.opacity(0.25),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: viewModel.timeRemaining <= 10
                    ? Color.red.opacity(0.7)
                    : .black.opacity(0.6),
                radius: 8
            )
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.timeRemaining
            )
    }
}

private func displayName(for character: Character?) -> String {
    guard let key = character?.key else { return "" }

    return loadCharacterDisplays()
        .first(where: { $0.key == key })?
        .name
        ?? key.replacingOccurrences(of: "_", with: " ").capitalized
}
