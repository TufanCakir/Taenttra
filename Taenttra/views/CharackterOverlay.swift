//
//  CharacterGridView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftUI

struct CharacterGridView: View {

    @EnvironmentObject var gameState: GameState
    @State private var characters: [CharacterDisplay] = loadCharacterDisplays()
    @State private var selectedIndex: Int = 0
    @State private var selectedSide: PlayerSide = .left

    private let columns = Array(
        repeating: GridItem(.fixed(72), spacing: 12),
        count: 3
    )

    // MARK: - Derived State

    private var selectedCharacter: CharacterDisplay? {
        guard characters.indices.contains(selectedIndex) else { return nil }
        return characters[selectedIndex]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                Text("CHOOSE YOUR FIGHTER")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.cyan)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(characters.enumerated()), id: \.element.id) {
                        index,
                        character in
                        CharacterSlot(
                            character: character,
                            isSelected: index == selectedIndex
                        )
                        .onTapGesture {
                            selectedIndex = index
                        }
                    }
                }

                Spacer()

                sideSelector

                startButton
            }
        }
        .onChange(of: characters.count) { oldCount, newCount in
            selectedIndex = min(selectedIndex, max(newCount - 1, 0))
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
        .padding(.bottom, 8)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button(action: startFight) {
            Text("START FIGHT")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.cyan)
                .cornerRadius(6)
        }
        .disabled(selectedCharacter?.locked ?? true)
        .opacity((selectedCharacter?.locked ?? true) ? 0.4 : 1)
    }

    // MARK: - Start Logic
    private func startFight() {
        guard let selected = selectedCharacter, !selected.locked else { return }

        let spriteSkin = SkinLibrary.spriteVariant(
            from: gameState.wallet?.equippedSkin
        )

        gameState.leftCharacter = Character(
            key: selected.key,
            isLocked: false,
            skinId: spriteSkin  // ✅ "red" | "base" | "shadow"
        )

        switch gameState.pendingMode {

        case .eventMode(let event):
            gameState.startEvent(mode: event)

        case .trainingMode(let mode):
            gameState.startTraining(mode: mode)

        case .survivalMode(let mode):
            gameState.startSurvival(mode: mode)

        case .arcadeStage(let stage):
            gameState.startArcade(stage: stage)

        case .story(let chapter, let section):
            gameState.startVersus(from: chapter, section: section)

        case .versus:
            let data = VersusLoader.load()
            gameState.versusViewModel = VersusViewModel(stages: data.stages)
            gameState.screen = .versus

        case .none:
            break
        }
    }
}

struct CharacterSlot: View {

    @EnvironmentObject var gameState: GameState
    let character: CharacterDisplay
    let isSelected: Bool

    private var imageName: String {
        SkinLibrary.previewImage(
            for: character.key,
            shopSkinId: gameState.wallet?.equippedSkin
        )
    }

    var body: some View {
        ZStack {
            if character.locked {
                Text("???")
                    .foregroundColor(.cyan)
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .offset(y: 30)
                    .clipped()
            }

            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    isSelected ? .cyan : .cyan.opacity(0.4),
                    lineWidth: isSelected ? 2 : 1
                )
        }
        .animation(.easeOut(duration: 0.15), value: imageName)
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
