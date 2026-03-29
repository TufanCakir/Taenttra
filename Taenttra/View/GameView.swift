//
//  GameView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI
import SwiftData

struct GameView: View {

    @EnvironmentObject var gameState: GameState

    @State private var hasLoadedPersistentState = false
    @StateObject private var storyViewModel = StoryViewModel()
    @StateObject private var arcadeViewModel = ArcadeViewModel()
    @StateObject private var survivalViewModel = SurvivalViewModel()
    @StateObject private var trainingViewModel = TrainingViewModel()
    @StateObject private var eventViewModel = EventViewModel()

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {

            // 🌑 GLOBAL GAME BACKGROUND
            AppBackgroundView(
                theme: BackgroundThemeService.theme(for: gameState.wallet?.selectedBackgroundThemeID)
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
        .task {
            loadPersistentStateIfNeeded()
        }
    }

    // MARK: - Screen Switch

    @ViewBuilder
    private var currentScreen: some View {
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

        case .backgrounds:
            BackgroundView()

        case .summon:
            SummonView()

        case .season:
            SeassonView()

        case .missiona:
            MissionaView()

        case .exchange:
            ExchangeView()

        case .gift:
            GiftView()

        case .daily:
            DailyView()

        case .skin:
            SkinSelectionView()

        case .cards:
            CardView()
        }
    }

    // MARK: - Versus Screen
    @ViewBuilder
    private var versusScreen: some View {
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
        } else {
            ProgressView("Preparing Fight…")
                .foregroundStyle(.white)
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
        navigateToCharacterSelect(for: .eventMode(event))
    }

    private func startTraining(_ mode: TrainingMode) {
        navigateToCharacterSelect(for: .trainingMode(mode))
    }

    private func startSurvival(_ mode: SurvivalMode) {
        navigateToCharacterSelect(for: .survivalMode(mode))
    }

    private func startArcade(_ stage: ArcadeStage) {
        navigateToCharacterSelect(for: .arcadeStage(stage))
    }

    private func startStoryFight(
        _ chapter: StoryChapter,
        _ section: StorySection
    ) {
        navigateToCharacterSelect(for: .story(chapter, section))
    }

    private func navigateToCharacterSelect(for mode: PendingMode) {
        gameState.pendingMode = mode
        gameState.screen = .characterSelect
    }

    // MARK: - Victory Handling

    private func handleVictory(_ rewards: VictoryRewards) {
        guard let wallet = gameState.wallet else { return }

        RewardManager.shared.apply(
            rewards: rewards,
            to: wallet
        )
        wallet.fightWins += 1
        wallet.dailyFightWins += 1
        wallet.weeklyFightWins += 1
        wallet.seasonPassXP += SeasonPassLoader.load().currentSeason?.fightWinXP ?? 40

        gameState.unlockStoryRewards()
        advanceStoryProgressIfNeeded()
        gameState.goBack()
    }

    // MARK: - Persistence
    private func loadPersistentStateIfNeeded() {
        guard !hasLoadedPersistentState else { return }
        hasLoadedPersistentState = true

        if gameState.wallet == nil {
            gameState.loadWallet(context: modelContext)
        }

        syncSeasonState()
        if let wallet = gameState.wallet {
            MissionResetService.syncResets(for: wallet, catalog: MissionLoader.load())
        }
        gameState.loadUnlockedModes()
        gameState.loadLastCompletedStorySection()

        // 🔥 Story korrekt rekonstruieren
        storyViewModel.rebuildUnlockedSections(using: gameState)
    }

    private func syncSeasonState() {
        guard let wallet = gameState.wallet else { return }

        let currentSeasonID = SeasonPassLoader.load().currentSeasonID
        guard wallet.currentSeasonID != currentSeasonID else { return }

        wallet.currentSeasonID = currentSeasonID
        wallet.seasonPassXP = 0
        wallet.claimedSeasonPassTierIDs = []
    }

    private func advanceStoryProgressIfNeeded() {
        guard case .story(_, let section) = gameState.pendingMode else { return }

        storyViewModel.unlockNextSection(after: section)
        gameState.unlockModes(after: section)
        gameState.lastCompletedStorySectionId = section.id
        gameState.saveLastCompletedStorySection()
    }
}
