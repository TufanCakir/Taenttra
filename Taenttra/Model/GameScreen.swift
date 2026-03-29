//
//  GameScreen.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
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
    case summon
    case season
    case missiona
    case exchange
    case gift
    case daily
    case options
    case shop
    case backgrounds
    case skin
    case cards
}

enum PendingMode {
    case story(StoryChapter, StorySection)
    case arcadeStage(ArcadeStage)
    case survivalMode(SurvivalMode)
    case trainingMode(TrainingMode)
    case eventMode(EventMode)
    case versus
}

@MainActor
final class GameState: ObservableObject {

    private enum Constants {
        static let defaultCharacterKey = "kenji"
        static let defaultEnemyRoster = ["kenji", "shiro", "reika", "rei"]
        static let defaultFightTime = 99
        static let quickVersusID = "quick_versus"
        static let quickVersusName = "Quick Versus"
        static let quickVersusBackground = "dojo_night"
        static let quickVersusMusic = "dojo_theme"
        static let unlockedModesKey = "unlocked_modes"
        static let lastStorySectionKey = "last_story_section"
    }

    @Published var characterDisplays: [CharacterDisplay] = []

    @Published var selectedCharacterKey: String = Constants.defaultCharacterKey

    func loadCharacterDisplays() -> [CharacterDisplay] {
        guard
            let url = Bundle.main.url(
                forResource: "characters",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(
                [CharacterDisplay].self,
                from: data
            )
        else {
            return []
        }

        return decoded
    }

    @Published var lastCompletedStorySectionId: String?

    @Published var unlockMessage: String?

    @Published var unlockedModes: Set<GameScreen> = [.story]

    @Published var playerSide: FighterSide = .left
    @Published var wallet: PlayerWallet?

    @Published var screen: GameScreen = .start
    @Published var pendingMode: PendingMode?

    @Published var leftCharacter: Character?
    @Published var rightCharacter: Character?

    @Published var currentStage: VersusStage?

    // 🔥 DAS ist die Quelle für Combat-State
    @Published var versusViewModel: VersusViewModel?

    @Published var leftHealth: CGFloat = 0
    @Published var rightHealth: CGFloat = 0
    @Published var time: Int = Constants.defaultFightTime

    @Published var equippedSkinSprite: String = "fighter_default"
    @Published var equippedSkin: String?  // frei wechselbar
    @Published var activeSkin: String?  // fight-locked

    func exitVersusAfterKO() {
        returnToHome(resetPendingMode: true)
    }

    func loadCharactersIfNeeded() {
        guard characterDisplays.isEmpty else { return }
        characterDisplays = loadCharacterDisplays()
    }

    private func saveUnlockedModes() {
        let rawValues = unlockedModes.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: Constants.unlockedModesKey)
    }

    func saveLastCompletedStorySection() {
        UserDefaults.standard.set(
            lastCompletedStorySectionId,
            forKey: Constants.lastStorySectionKey
        )
    }

    func loadLastCompletedStorySection() {
        lastCompletedStorySectionId =
            UserDefaults.standard.string(forKey: Constants.lastStorySectionKey)
    }

    func loadUnlockedModes() {
        guard
            let rawValues = UserDefaults.standard.array(
                forKey: Constants.unlockedModesKey
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
            if existing.unlockedCharacters.isEmpty {
                existing.unlockedCharacters.append(Constants.defaultCharacterKey)
            }

            let defaultThemeID = BackgroundThemeLoader.load().defaultThemeID
            if !existing.ownedBackgroundThemeIDs.contains(defaultThemeID) {
                existing.ownedBackgroundThemeIDs.append(defaultThemeID)
            }

            if existing.selectedBackgroundThemeID.isEmpty {
                existing.selectedBackgroundThemeID = defaultThemeID
            }

            let battleCardCatalog = BattleCardLoader.load()
            if existing.ownedBattleCardIDs.isEmpty {
                existing.ownedBattleCardIDs = BattleDeckService.starterOwnedCardIDs(from: battleCardCatalog)
            }

            if existing.deckSlotPayloads.isEmpty {
                existing.deckSlotPayloads = BattleDeckService.defaultSlotPayloads(from: battleCardCatalog)
            }

            equippedSkin = existing.equippedSkin

            return
        }

        let newWallet = PlayerWallet()
        let battleCardCatalog = BattleCardLoader.load()
        newWallet.ownedBattleCardIDs = BattleDeckService.starterOwnedCardIDs(from: battleCardCatalog)
        newWallet.deckSlotPayloads = BattleDeckService.defaultSlotPayloads(from: battleCardCatalog)
        context.insert(newWallet)
        wallet = newWallet
        equippedSkin = newWallet.equippedSkin
    }

    func startQuickVersus() {
        let player = Character.player(
            key: selectedCharacterKey,
            skinId: activeSkin
        )
        leftCharacter = player

        let enemyPool = Constants.defaultEnemyRoster
            .filter { $0 != selectedCharacterKey }
            .shuffled()

        let enemies = enemyPool.isEmpty ? Constants.defaultEnemyRoster : enemyPool
        let openingEnemy = enemies.first ?? Constants.defaultCharacterKey
        let stage = makeStage(
            id: Constants.quickVersusID,
            name: Constants.quickVersusName,
            background: Constants.quickVersusBackground,
            music: Constants.quickVersusMusic,
            enemies: enemies,
            timeLimit: 60
        )

        rightCharacter = Character.enemy(
            key: openingEnemy,
            skinId: "base"
        )
        pendingMode = .versus
        startVersusStage(stage)
    }

    func syncSkin(from wallet: PlayerWallet, skins: [SkinItem]) {
        equippedSkin = wallet.equippedSkin

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

    private func resetFightState(resetPendingMode: Bool) {
        versusViewModel = nil
        leftCharacter = nil
        rightCharacter = nil
        currentStage = nil
        activeSkin = nil
        time = Constants.defaultFightTime

        if resetPendingMode {
            pendingMode = nil
        }
    }

    private func returnToHome(resetPendingMode: Bool) {
        AudioManager.shared.endFight()
        resetFightState(resetPendingMode: resetPendingMode)
        screen = .home
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
        case .characterSelect, .story, .versus, .arcade, .training, .survival, .events:
            returnToHome(resetPendingMode: true)
        case .summon:
            returnToHome(resetPendingMode: false)
        case .season, .missiona, .exchange, .gift, .daily:
            screen = .summon
        case .cards:
            screen = .summon
        case .backgrounds:
            screen = .shop
        case .shop, .skin, .options:
            returnToHome(resetPendingMode: false)
        default:
            screen = .home
        }
    }

    private func startVersusStage(_ stage: VersusStage) {
        // 🎵 Musik via SongLibrary
        AudioManager.shared.playFightMusic(key: stage.music)

        currentStage = stage
        time = stage.waves.first?.timeLimit ?? Constants.defaultFightTime
        versusViewModel = VersusViewModel(
            stages: [stage],
            gameState: self
        )
        screen = .versus
    }

    func startEvent(mode: EventMode) {
        let stage = makeStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            enemies: [mode.enemy],
            timeLimit: mode.timeLimit
        )

        startVersusStage(stage)
    }

    func startTraining(mode: TrainingMode) {
        let stage = makeStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            enemies: [mode.enemy],
            timeLimit: mode.timeLimit
        )

        startVersusStage(stage)
    }

    func startSurvival(mode: SurvivalMode) {
        let enemy = mode.enemyPool.randomElement() ?? Constants.defaultCharacterKey
        let stage = makeStage(
            id: mode.id,
            name: mode.title,
            background: mode.background,
            music: mode.music,
            enemies: [enemy],
            timeLimit: mode.timeLimit
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
                    : section.enemies.last ?? Constants.defaultCharacterKey

                return VersusWave(
                    wave: index + 1,
                    enemies: [enemy],
                    timeLimit: section.timeLimit
                )
            }
        )

        startVersusStage(stage)
    }

    private func makeStage(
        id: String,
        name: String,
        background: String,
        music: String,
        enemies: [String],
        timeLimit: Int
    ) -> VersusStage {
        VersusStage(
            id: id,
            name: name,
            background: background,
            music: music,
            waves: [
                VersusWave(
                    wave: 1,
                    enemies: enemies,
                    timeLimit: timeLimit
                )
            ]
        )
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
