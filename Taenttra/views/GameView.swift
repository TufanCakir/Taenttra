//
//  GameView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//
import SwiftUI

struct GameView: View {

    @EnvironmentObject var gameState: GameState

    @StateObject private var storyViewModel = StoryViewModel()
    @StateObject private var arcadeViewModel = ArcadeViewModel()
    @StateObject private var survivalViewModel = SurvivalViewModel()
    @StateObject private var trainingViewModel = TrainingViewModel()
    @StateObject private var eventViewModel = EventViewModel()

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {

                // 🔹 MAIN SCREEN SWITCH
                switch gameState.screen {
                case .start:
                    StartView()

                case .home:
                    HomeView()

                case .leaderboard:
                    LeaderboardView()

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
                        let right = gameState.rightCharacter,
                        let vm = gameState.versusViewModel
                    {
                        VersusView(
                            viewModel: vm,
                            onVictoryContinue: { rewards in

                                // 💰 Rewards
                                gameState.wallet.coins += rewards.coins
                                gameState.wallet.crystals += rewards.crystals
                                gameState.wallet.tournamentShards +=
                                    rewards.tournamentShards

                                // 🔓 Characters
                                gameState.unlockStoryRewards()

                                // 🔓 Sections + MODES
                                if case .story(_, let section) = gameState
                                    .pendingMode
                                {
                                    storyViewModel.unlockNextSection(
                                        after: section
                                    )
                                    gameState.unlockModes(after: section)
                                    gameState.lastCompletedStorySectionId =
                                        section.id
                                    gameState.saveLastCompletedStorySection()
                                }

                                // 🧹 Cleanup
                                gameState.versusViewModel = nil
                                gameState.pendingMode = nil
                                gameState.screen = .home
                            },
                            leftCharacter: left,
                            rightCharacter: right
                        )
                    }

                case .arcade:
                    ArcadeView(
                        viewModel: arcadeViewModel,
                        onStartArcade: { stage in
                            gameState.pendingMode = .arcadeStage(stage)
                            gameState.screen = .characterSelect
                        }
                    )

                case .shop:
                    ShopView()

                case .skin:
                    SkinSelectionView()
                }

                // 🔓 UNLOCK FEEDBACK OVERLAY
                if let message = gameState.unlockMessage {
                    VStack {
                        Spacer()

                        Text(message)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.black.opacity(0.85))
                            .cornerRadius(12)
                            .padding(.bottom, 60)
                            .transition(
                                .move(edge: .bottom)
                                    .combined(with: .opacity)
                            )
                    }
                    .zIndex(50)  // 🔥 wichtig
                    .animation(.spring(), value: message)
                }
            }
            .environmentObject(gameState)
            .toolbar {
                if gameState.showsBackButton {
                    ToolbarItem(placement: .navigationBarLeading) {
                        GameBackButton {
                            gameState.goBack()
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: gameState.screen)
        }
        .onAppear {
            if gameState.wallet == nil {
                gameState.loadWallet(context: modelContext)
            }

            gameState.loadUnlockedModes()
            gameState.loadLastCompletedStorySection()
        }
    }
}
