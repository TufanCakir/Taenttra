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
        VStack {
            ZStack {

                HStack {
                    // 🟦 PLAYER
                    SlantedPlayerHUD(
                        name: displayName(for: gameState.leftCharacter),
                        health: viewModel.leftHealth,
                        direction: .left
                    )

                    Spacer()

                    // 🟥 ENEMY
                    SlantedPlayerHUD(
                        name: displayName(for: gameState.rightCharacter),
                        health: viewModel.rightHealth,
                        direction: .right
                    )
                }

                Text("\(viewModel.timeRemaining)")
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(
                        viewModel.timeRemaining <= 10 ? .red : .white
                    )
            }
            .padding()

            Spacer()
        }
    }
}

private func displayName(for character: Character?) -> String {
    guard let key = character?.key else { return "" }

    return loadCharacterDisplays()
        .first(where: { $0.key == key })?
        .name
        ?? key.replacingOccurrences(of: "_", with: " ").capitalized
}
