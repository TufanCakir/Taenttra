//
//  GameView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//
import SwiftUI

struct GameView: View {

    @StateObject private var gameState = GameState()
    @StateObject private var storyViewModel = StoryViewModel()
    @StateObject private var arcadeViewModel = ArcadeViewModel()
    @StateObject private var survivalViewModel = SurvivalViewModel()
    @StateObject private var trainingViewModel = TrainingViewModel()
    @StateObject private var eventViewModel = EventViewModel()

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
                
            case .options:
                SettingsView()
                
            case .events:
                EventView(
                    viewModel: eventViewModel,
                    onStartEvent: { event in
                        gameState.pendingMode = .eventMode(event)
                        gameState.screen = .characterSelect
                    }
                )
                
            case .training:
                TrainingView(
                    viewModel: trainingViewModel,
                    onStartTraining: { mode in
                        gameState.pendingMode = .trainingMode(mode)
                        gameState.screen = .characterSelect
                    }
                )
                
            case .survival:
                SurvivalView(
                    viewModel: survivalViewModel,
                    onStartSurvival: { mode in
                        gameState.pendingMode = .survivalMode(mode)
                        gameState.screen = .characterSelect
                    }
                )

            case .story:
                StoryView(
                    viewModel: storyViewModel,
                    onStartFight: { chapter, section in
                        gameState.pendingMode = .story(chapter, section)
                        gameState.screen = .characterSelect
                    }
                )

            case .characterSelect:
                CharacterGridView()

            case .versus:
                if let left = gameState.leftCharacter,
                   let vm = gameState.versusViewModel {

                    VersusView(
                        viewModel: vm,
                        onVictoryContinue: { rewards in
                            rewardStore.add(
                                coins: rewards.coins,
                                crystals: rewards.crystals
                            )
                            gameState.versusViewModel = nil
                            gameState.screen = .story // 👈 Story-Flow
                        },
                        leftCharacter: left
                    )

                    GameHUDView(viewModel: vm)
                }

            case .arcade:
                ArcadeView(
                    viewModel: arcadeViewModel,
                    onStartArcade: { stage in
                        gameState.pendingMode = .arcadeStage(stage)
                        gameState.screen = .characterSelect
                    }
                )
            }
        }
        .environmentObject(gameState)
        .animation(.easeInOut(duration: 0.25), value: gameState.screen)
    }
}

#Preview {
    GameView()
}
