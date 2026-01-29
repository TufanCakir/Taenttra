//
//  GameScreen.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Combine
import Foundation
import SwiftData

enum GameScreen: String, CaseIterable, Codable {
    case start
    case home
    case characterSelect
    case versus
    case arcade
    case story
    case survival
    case training
    case events
    case options
    case shop
    case leaderboard
    case skin
}

enum PendingMode {
    case story(StoryChapter, StorySection)
    case arcadeStage(ArcadeStage)
    case survivalMode(SurvivalMode)
    case trainingMode(TrainingMode)
    case eventMode(EventMode)
    case versus
}

final class GameState: ObservableObject {

    private let unlockedModesKey = "unlocked_modes"

    @Published var unlockMessage: String?

    @Published var unlockedModes: Set<GameScreen> = [.story]

    @Published var playerSide: PlayerSide = .left
    @Published var wallet: PlayerWallet!

    @Published var screen: GameScreen = .start
    @Published var pendingMode: PendingMode?

    @Published var leftCharacter: Character?
    @Published var rightCharacter: Character?

    @Published var currentStage: VersusStage?

    // 🔥 DAS ist die Quelle für Combat-State
    @Published var versusViewModel: VersusViewModel?

    @Published var leftHealth: CGFloat = 0
    @Published var rightHealth: CGFloat = 0
    @Published var time: Int = 99

    @Published var equippedSkinSprite: String = "fighter_default"
    @Published var equippedSkin: String?  // frei wechselbar
    @Published var activeSkin: String?  // fight-locked

    private func saveUnlockedModes() {
        let rawValues = unlockedModes.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: unlockedModesKey)
    }

    func loadUnlockedModes() {
        guard
            let rawValues = UserDefaults.standard.array(
                forKey: unlockedModesKey
            ) as? [String]
        else {
            unlockedModes = [.story]
            return
        }

        unlockedModes = Set(
            rawValues.compactMap { GameScreen(rawValue: $0) }
        )
    }

    func loadWallet(context: ModelContext) {
        let fetch = FetchDescriptor<PlayerWallet>()

        if let existing = try? context.fetch(fetch).first {
            wallet = existing

            // 🔥 MIGRATION FIX
            if wallet.unlockedCharacters.isEmpty {
                wallet.unlockedCharacters.append("kenji")
            }

            return
        }

        let newWallet = PlayerWallet()
        context.insert(newWallet)
        wallet = newWallet
    }

    func syncSkin(from wallet: PlayerWallet, skins: [SkinItem]) {
        guard let equipped = wallet.equippedSkin,
            let skin = skins.first(where: { $0.id == equipped })
        else {
            equippedSkinSprite = "fighter_default"
            return
        }

        equippedSkinSprite = skin.fighterSprite
    }

    func unlockStoryRewards() {
        guard
            let wallet = wallet,
            case .story(_, let section) = pendingMode,
            let unlocks = section.unlocks
        else { return }

        for key in unlocks {
            if !wallet.unlockedCharacters.contains(key) {
                wallet.unlockedCharacters.append(key)
            }
        }
    }
}

extension GameState {

    var showsBackButton: Bool {
        switch screen {
        case .home, .start:
            return false
        default:
            return true
        }
    }

    func goBack() {
        switch screen {

        case .story, .versus:
            AudioManager.shared.endFight()
            screen = .home

        case .shop, .skin, .options:
            AudioManager.shared.endFight()
            screen = .home

        case .arcade, .training, .survival, .events:
            AudioManager.shared.endFight()
            screen = .home

        case .characterSelect:
            screen = .home

        default:
            screen = .home
        }
    }

    private func startVersusStage(_ stage: VersusStage) {

        // 🎵 Musik via SongLibrary
        AudioManager.shared.playFightMusic(key: stage.music)

        currentStage = stage
        versusViewModel = VersusViewModel(
            stages: [stage],
            gameState: self
        )
        screen = .versus
    }

    func startEvent(mode: EventMode) {
        let stage = VersusStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            waves: [
                VersusWave(
                    wave: 1,
                    enemies: [mode.enemy],
                    timeLimit: mode.timeLimit
                )
            ]
        )

        startVersusStage(stage)
    }

    func startTraining(mode: TrainingMode) {
        let stage = VersusStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            waves: [
                VersusWave(
                    wave: 1,
                    enemies: [mode.enemy],
                    timeLimit: mode.timeLimit
                )
            ]
        )

        startVersusStage(stage)
    }

    func startSurvival(mode: SurvivalMode) {
        let enemy = mode.enemyPool.randomElement() ?? "kenji"

        let stage = VersusStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            waves: [
                VersusWave(
                    wave: 1,
                    enemies: [enemy],
                    timeLimit: mode.timeLimit
                )
            ]
        )

        startVersusStage(stage)
    }

    func startArcade(stage: ArcadeStage) {
        let waves = (0..<stage.waves).map {
            VersusWave(
                wave: $0 + 1,
                enemies: [stage.enemy],
                timeLimit: stage.timeLimit
            )
        }

        let versusStage = VersusStage(
            id: stage.id,
            name: stage.title,
            background: stage.background,
            music: stage.music,
            waves: waves
        )

        startVersusStage(versusStage)
    }

    func startVersus(from chapter: StoryChapter, section: StorySection) {

        let music = section.music ?? chapter.music

        let background =
            section.arena.isEmpty
            ? chapter.background
            : section.arena

        let stage = VersusStage(
            id: section.id,
            name: section.title,
            background: background,
            music: music,
            waves: (0..<section.waves).map { index in
                let enemy =
                    section.enemies.indices.contains(index)
                    ? section.enemies[index]
                    : section.enemies.last ?? "kenji"

                return VersusWave(
                    wave: index + 1,
                    enemies: [enemy],
                    timeLimit: section.timeLimit
                )
            }
        )

        startVersusStage(stage)
    }
}

extension GameState {

    func unlockModes(after section: StorySection) {

        var unlocked: [String] = []

        switch section.id {
        case "1_2":
            unlockedModes.insert(.training)
            unlocked.append("Training")
        case "1_3":
            unlockedModes.insert(.arcade)
            unlocked.append("Arcade")
        case "1_4":
            unlockedModes.insert(.versus)
            unlocked.append("Versus")
        case "1_5":
            unlockedModes.insert(.events)
            unlocked.append("Events")
        case "1_6":
            unlockedModes.insert(.survival)
            unlocked.append("Survival")
        case "1_7":
            unlockedModes.formUnion([.shop, .skin, .leaderboard])
            unlocked.append(contentsOf: ["Shop", "Skins", "Ranking"])
        default:
            break
        }

        guard !unlocked.isEmpty else { return }

        saveUnlockedModes()  // ✅ WICHTIG

        unlockMessage = "Freigeschaltet: " + unlocked.joined(separator: ", ")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.unlockMessage = nil
        }
    }
}
