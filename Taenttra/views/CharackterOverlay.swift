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

    let columns = Array(
        repeating: GridItem(.fixed(72), spacing: 12),
        count: 3
    )

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                Text("CHOOSE YOUR FIGHTER")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.cyan)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(characters.indices, id: \.self) { index in
                        CharacterSlot(
                            character: characters[index],
                            isSelected: selectedIndex == index
                        )
                        .onTapGesture {
                            selectedIndex = index
                        }
                    }
                }

                Spacer()
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

                // 🔥 CONFIRM
                Button {
                    print("🟢 START FIGHT tapped")

                    let selected = characters[selectedIndex]
                    print("Selected:", selected.key, "locked:", selected.locked)

                    guard !selected.locked else {
                        print("⛔️ Character is locked")
                        return
                    }

                    let player = selected.toCharacter()
                    // 🔥 STAGE FESTLEGEN
                    let versusData = VersusLoader.load()
                    gameState.versusViewModel = VersusViewModel(
                        stages: versusData.stages
                    )
                    gameState.leftCharacter = player
                    gameState.screen = .versus

                } label: {
                    Text("START FIGHT")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.cyan)
                        .cornerRadius(6)
                }
            }
        }
    }
}

struct SideButton: View {
    let title: String
    let side: PlayerSide
    @Binding var selectedSide: PlayerSide

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(
                selectedSide == side ? .black : .cyan
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                selectedSide == side ? Color.cyan : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.cyan, lineWidth: 1)
            )
            .cornerRadius(4)
            .onTapGesture {
                selectedSide = side
            }
    }
}

struct CharacterSlot: View {

    let character: CharacterDisplay
    let isSelected: Bool

    var body: some View {
        ZStack {
            if character.locked {
                Text("???")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.cyan)
            } else {
                Image(character.displayImage)  // 🔥 AUS JSON
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .offset(y: 30)
                    .saturation(0.85)
                    .contrast(1.05)
                    .clipped()
            }

            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    isSelected ? Color.cyan : Color.cyan.opacity(0.4),
                    lineWidth: isSelected ? 2 : 1
                )
        }
        .frame(width: 72, height: 72)
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    CharacterGridView()
        .environmentObject(GameState())
}
