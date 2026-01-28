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

    private var activeODRTags: Set<String> = []

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

        // 🧹 ODR freigeben (wenn aktiv)
        if !activeODRTags.isEmpty {
            ODRManager.shared.release(tags: activeODRTags)
            activeODRTags.removeAll()
        }

        // 🎵 Fight-Musik nur beenden, wenn wir aus einem Kampf kommen
        switch screen {
        case .versus, .story, .arcade, .training, .survival, .events:
            AudioManager.shared.endFight()
        default:
            break
        }

        // 🏠 Immer zurück ins Home
        screen = .home
    }

    private func startVersusStage(_ stage: VersusStage) {

        let tags: Set<String> = [
            "stage_\(stage.id)",
            "music_\(stage.music)",
            "enemy_\(stage.waves.first?.enemies.first ?? "")",
        ]

        activeODRTags = tags

        ODRManager.shared.load(tags: tags) { success in
            guard success else { return }

            DispatchQueue.main.async {
                AudioManager.shared.playFightMusic(key: stage.music)
                self.currentStage = stage
                self.versusViewModel = VersusViewModel(stages: [stage])
                self.screen = .versus
            }
        }
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

        let stage = VersusStage(
            id: section.id,
            name: section.title,
            background: chapter.background,
            music: music,
            waves: (0..<section.waves).map {
                VersusWave(
                    wave: $0 + 1,
                    enemies: [section.enemy],
                    timeLimit: section.timeLimit
                )
            }
        )

        startVersusStage(stage)
    }
}
