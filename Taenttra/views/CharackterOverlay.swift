//
//  CharacterGridView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftUI

struct CharacterGridView: View {

    @EnvironmentObject var gameState: GameState
    private let characters: [CharacterDisplay] = loadCharacterDisplays()

    @State private var selectedIndex: Int = 0
    @State private var selectedSide: PlayerSide = .left

    private var selectedCharacter: CharacterDisplay? {
        guard characters.indices.contains(selectedIndex) else { return nil }
        return characters[selectedIndex]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {

                Text("CHOOSE YOUR FIGHTER")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.cyan)

                versusPreview

                characterRoster

                Spacer()

                sideSelector

                startButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - VS Preview
    private var versusPreview: some View {
        HStack(spacing: 24) {

            // PLAYER
            VStack(spacing: 8) {
                if let selected = selectedCharacter {
                    Image(selected.previewImage(using: gameState.wallet))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)
                }

                Text(selectedCharacter?.name.uppercased() ?? "PLAYER")
                    .font(.caption.bold())
                    .foregroundStyle(.cyan)
            }

            Text("VS")
                .font(.system(size: 42, weight: .heavy))
                .foregroundStyle(.red)

            // ENEMY
            VStack(spacing: 8) {
                Image(enemyPreviewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)

                Text(enemyDisplayName.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Character Roster (wie Home)
    private var characterRoster: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(characters.enumerated()), id: \.element.id) {
                    index,
                    character in
                    rosterItem(character, index: index)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func rosterItem(
        _ character: CharacterDisplay,
        index: Int
    ) -> some View {

        let isSelected = index == selectedIndex
        let locked = isLocked(character)

        return Image(character.displayImage)
            .resizable()
            .scaledToFill()
            .frame(
                width: isSelected ? 68 : 56,
                height: isSelected ? 68 : 56
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.cyan : .clear, lineWidth: 3)
            )
            .opacity(locked ? 0.3 : 1)
            .onTapGesture {
                guard !locked else { return }
                withAnimation(.spring()) {
                    selectedIndex = index
                }
            }
    }

    // MARK: - Side Selector
    private var sideSelector: some View {
        HStack(spacing: 24) {
            SideButton(
                title: "LEFT",
                side: .left,
                selectedSide: $selectedSide
            )

            SideButton(
                title: "RIGHT",
                side: .right,
                selectedSide: $selectedSide
            )
        }
    }

    // MARK: - Start Button
    private var startButton: some View {
        Button(action: startFight) {
            Text("START FIGHT")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.black)
                .padding(.horizontal, 48)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
        }
        .disabled(selectedCharacter.map(isLocked) ?? true)
        .opacity((selectedCharacter.map(isLocked) ?? true) ? 0.4 : 1)
    }

    // MARK: - Helpers
    private func isLocked(_ character: CharacterDisplay) -> Bool {
        guard let wallet = gameState.wallet else { return true }
        return !wallet.unlockedCharacters.contains(character.key)
    }

    private var enemyPreviewImage: String {
        if let key = enemyKey,
            let enemy = characters.first(where: { $0.key == key })
        {
            return enemy.displayImage
        }
        return "kenji_base_preview"
    }

    private var enemyDisplayName: String {
        guard
            let key = enemyKey,
            let enemy = characters.first(where: { $0.key == key })
        else {
            return "RIVAL"
        }
        return enemy.name
    }

    private var enemyKey: String? {
        switch gameState.pendingMode {
        case .story(_, let section): return section.enemies.first
        case .arcadeStage(let stage): return stage.enemy
        case .trainingMode(let mode): return mode.enemy
        case .eventMode(let mode): return mode.enemy
        case .survivalMode(let mode): return mode.enemyPool.first
        case .versus:
            return gameState.currentStage?.waves.first?.enemies.first
        case .none:
            return nil
        }
    }

    private func startFight() {
        guard let selected = selectedCharacter, !isLocked(selected) else {
            return
        }

        gameState.playerSide = selectedSide

        let spriteSkin = SkinLibrary.spriteVariant(
            from: gameState.wallet?.equippedSkin
        )

        let playerCharacter = Character(
            key: selected.key,
            combatSpritePrefix: selected.combatSpritePrefix,
            isLocked: false,
            skinId: spriteSkin
        )

        let enemyCharacter = Character.enemy(
            key: enemyKey ?? "kenji",
            skinId: nil
        )

        if selectedSide == .left {
            gameState.leftCharacter = playerCharacter
            gameState.rightCharacter = enemyCharacter
        } else {
            gameState.leftCharacter = enemyCharacter
            gameState.rightCharacter = playerCharacter
        }

        switch gameState.pendingMode {
        case .eventMode(let event): gameState.startEvent(mode: event)
        case .trainingMode(let mode): gameState.startTraining(mode: mode)
        case .survivalMode(let mode): gameState.startSurvival(mode: mode)
        case .arcadeStage(let stage): gameState.startArcade(stage: stage)
        case .story(let chapter, let section):
            gameState.startVersus(from: chapter, section: section)
        case .versus:
            let data = VersusLoader.load()
            gameState.versusViewModel = VersusViewModel(
                stages: data.stages,
                gameState: gameState
            )
            gameState.screen = .versus
        case .none:
            break
        }
    }

    private var enemySkinId: String? {
        switch gameState.pendingMode {

        case .story(_, let section):
            return section.boss == true ? "boss" : nil

        case .eventMode:
            return "event"

        case .arcadeStage:
            return nil

        case .trainingMode:
            return nil

        case .survivalMode:
            return nil

        case .versus:
            return nil

        case .none:
            return nil
        }
    }

}

struct CharacterSlot: View {

    @EnvironmentObject var gameState: GameState

    let character: CharacterDisplay
    let isSelected: Bool
    let locked: Bool

    var body: some View {
        ZStack {
            if locked {
                Text("???")
                    .foregroundColor(.cyan)
            } else {
                Image(character.displayImage)
                    .resizable()
                    .scaledToFill()
            }

            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    isSelected ? .cyan : .cyan.opacity(0.25),
                    lineWidth: isSelected ? 2.5 : 1
                )
        }
    }
}

struct SideButton: View {
    let title: String
    let side: PlayerSide
    @Binding var selectedSide: PlayerSide

    var isSelected: Bool { selectedSide == side }

    var body: some View {
        Button(action: { selectedSide = side }) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? .black : .cyan)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.cyan : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            Color.cyan.opacity(isSelected ? 1 : 0.6),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CharacterGridView()
        .environmentObject(GameState())
}
