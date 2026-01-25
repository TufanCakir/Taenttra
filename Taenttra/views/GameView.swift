//
//  GameView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//
import SwiftUI

struct GameView: View {

    @StateObject private var gameState = GameState()
    @Environment(\.modelContext) private var modelContext

    private var rewardStore: RewardStore {
        RewardStore(context: modelContext)
    }

    var body: some View {
        ZStack {
            switch gameState.screen {

            case .start:
                StartView()

            case .home:
                HomeView()

            case .characterSelect:
                CharacterGridView()

            case .versus:
                if let left = gameState.leftCharacter,
                    let vm = gameState.versusViewModel
                {

                    VersusView(
                        viewModel: vm,
                        onVictoryContinue: { rewards in

                            rewardStore.add(
                                coins: rewards.coins,
                                crystals: rewards.crystals
                            )

                            gameState.versusViewModel = nil  // 🔥 reset
                            gameState.screen = .home
                        },
                        leftCharacter: left
                    )

                    GameHUDView(viewModel: vm)
                }

            case .arcade:
                Text("ARCADE")
            }
        }
        .environmentObject(gameState)
        .animation(.easeInOut(duration: 0.25), value: gameState.screen)
    }
}

#Preview {
    GameView()
}
