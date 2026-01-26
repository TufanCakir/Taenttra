//
//  GameScreen.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Combine
import Foundation
import SwiftData

enum GameScreen {
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

    func loadWallet(context: ModelContext) {
        let fetch = FetchDescriptor<PlayerWallet>()

        if let existing = try? context.fetch(fetch).first {
            wallet = existing
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
        case .shop, .skin, .options:
            screen = .home

        case .arcade, .story, .training, .survival, .events:
            screen = .home

        case .characterSelect:
            screen = .home

        default:
            screen = .home
        }
    }

    func startEvent(mode: EventMode) {

        let wave = VersusWave(
            wave: 1,
            enemies: [mode.enemy],
            timeLimit: mode.timeLimit
        )

        let stage = VersusStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            waves: [wave]
        )

        currentStage = stage
        versusViewModel = VersusViewModel(stages: [stage])
        screen = .versus
    }

    func startTraining(mode: TrainingMode) {

        let wave = VersusWave(
            wave: 1,
            enemies: [mode.enemy],
            timeLimit: mode.timeLimit
        )

        let stage = VersusStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            waves: [wave]
        )

        currentStage = stage
        versusViewModel = VersusViewModel(stages: [stage])
        screen = .versus
    }

    func startSurvival(mode: SurvivalMode) {

        let randomEnemy = mode.enemyPool.randomElement() ?? "kenji"

        let wave = VersusWave(
            wave: 1,
            enemies: [randomEnemy],
            timeLimit: mode.timeLimit
        )

        let stage = VersusStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            waves: [wave]
        )

        currentStage = stage
        versusViewModel = VersusViewModel(stages: [stage])
        screen = .versus
    }

    func startArcade(stage: ArcadeStage) {

        let waves = (0..<stage.waves).map { index in
            VersusWave(
                wave: index + 1,
                enemies: [stage.enemy],
                timeLimit: 99
            )
        }

        let versusStage = VersusStage(
            id: stage.id,
            name: stage.title,
            background: stage.background,
            music: stage.music,
            waves: waves
        )

        currentStage = versusStage
        versusViewModel = VersusViewModel(stages: [versusStage])
        screen = .versus
    }

    func startVersus(from chapter: StoryChapter, section: StorySection) {

        // 🔒 Skin für den Fight fixieren
        activeSkin = equippedSkin

        // 1️⃣ Stage aus Story-Daten bauen
        let stage = VersusStage(
            id: section.id,
            name: chapter.title,
            background: chapter.background,
            music: chapter.music,
            waves: (0..<section.waves).map { index in
                VersusWave(
                    wave: index + 1,
                    enemies: [section.enemy],
                    timeLimit: 99
                )
            }
        )

        // 2️⃣ Stage speichern
        currentStage = stage

        // 3️⃣ VersusViewModel NEU erzeugen
        versusViewModel = VersusViewModel(
            stages: [stage]
        )

        // 4️⃣ Screen wechseln
        screen = .versus
    }
}

