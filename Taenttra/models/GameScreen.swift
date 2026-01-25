//
//  GameScreen.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Combine
import Foundation

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
}

extension GameState {
    
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
