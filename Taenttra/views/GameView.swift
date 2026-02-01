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
        ZStack {

            // 🌑 GLOBAL GAME BACKGROUND
            LinearGradient(
                colors: [.black, .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 🎮 ACTIVE SCREEN
            currentScreen
                .transition(sceneTransition)
                .zIndex(1)

            // 🔓 UNLOCK OVERLAY
            unlockOverlay
                .zIndex(10)
        }
        .environmentObject(gameState)
        .animation(.easeInOut(duration: 0.25), value: gameState.screen)
        .onAppear(perform: loadPersistentState)
    }

    // MARK: - Screen Switch

    @ViewBuilder
    private var currentScreen: some View {
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
                onStartEvent: startEvent
            )

        case .training:
            TrainingView(
                viewModel: trainingViewModel,
                onStartTraining: startTraining
            )

        case .survival:
            SurvivalView(
                viewModel: survivalViewModel,
                onStartSurvival: startSurvival
            )

        case .story:
            StoryView(
                viewModel: storyViewModel,
                onStartFight: startStoryFight
            )

        case .characterSelect:
            CharacterGridView()

        case .versus:
            versusScreen

        case .arcade:
            ArcadeView(
                viewModel: arcadeViewModel,
                onStartArcade: startArcade
            )

        case .shop:
            ShopView()

        case .skin:
            SkinSelectionView()
        }
    }

    // MARK: - Versus Screen
    @ViewBuilder
    private var versusScreen: some View {

        // 🥊 FIGHT
        if let left = gameState.leftCharacter,
            let right = gameState.rightCharacter,
            let vm = gameState.versusViewModel
        {

            VersusView(
                viewModel: vm,
                onVictoryContinue: handleVictory,
                leftCharacter: left,
                rightCharacter: right
            )
        }
    }

    // MARK: - Scene Transition

    private var sceneTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 1.03)),
            removal: .opacity
                .combined(with: .scale(scale: 0.97))
        )
    }

    // MARK: - Unlock Overlay

    @ViewBuilder
    private var unlockOverlay: some View {
        if let message = gameState.unlockMessage {
            VStack {
                Spacer()

                Text(message)
                    .font(.system(size: 14, weight: .heavy))
                    .tracking(1.2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.85))
                            .overlay(
                                Capsule()
                                    .stroke(
                                        Color.cyan.opacity(0.6),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: .cyan.opacity(0.5), radius: 12)
                    .padding(.bottom, 80)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Navigation Helpers

    private func startEvent(_ event: EventMode) {
        gameState.pendingMode = .eventMode(event)
        gameState.screen = .characterSelect
    }

    private func startTraining(_ mode: TrainingMode) {
        gameState.pendingMode = .trainingMode(mode)
        gameState.screen = .characterSelect
    }

    private func startSurvival(_ mode: SurvivalMode) {
        gameState.pendingMode = .survivalMode(mode)
        gameState.screen = .characterSelect
    }

    private func startArcade(_ stage: ArcadeStage) {
        gameState.pendingMode = .arcadeStage(stage)
        gameState.screen = .characterSelect
    }

    private func startStoryFight(
        _ chapter: StoryChapter,
        _ section: StorySection
    ) {
        gameState.pendingMode = .story(chapter, section)
        gameState.screen = .characterSelect
    }

    // MARK: - Victory Handling

    private func handleVictory(_ rewards: VictoryRewards) {

        // 💰 Rewards
        gameState.wallet.coins += rewards.coins
        gameState.wallet.crystals += rewards.crystals
        gameState.wallet.tournamentShards += rewards.tournamentShards

        // 🔓 Unlocks
        gameState.unlockStoryRewards()

        if case .story(_, let section) = gameState.pendingMode {
            storyViewModel.unlockNextSection(after: section)
            gameState.unlockModes(after: section)
            gameState.lastCompletedStorySectionId = section.id
            gameState.saveLastCompletedStorySection()
        }

        // 🧹 Cleanup
        gameState.versusViewModel = nil
        gameState.pendingMode = nil
        gameState.screen = .home
    }

    // MARK: - Persistence

    private func loadPersistentState() {
        if gameState.wallet == nil {
            gameState.loadWallet(context: modelContext)
        }

        gameState.loadUnlockedModes()
        gameState.loadLastCompletedStorySection()
    }
}
