//
//  HomeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    private enum Layout {
        static let rosterSpacing: CGFloat = 12
        static let rosterHorizontalPadding: CGFloat = 16
        static let selectedRosterSize: CGFloat = 68
        static let rosterSize: CGFloat = 56
        static let mainPreviewHeight: CGFloat = 270
        static let placeholderHeight: CGFloat = 260
    }

    @EnvironmentObject var gameState: GameState

    @State private var idlePulse = false

    private let items: [HomeMenuItem] = [
        .story,
        .events,
        .training,
        .arcade,
        .survival,
        .versus,
        .shop,
        .skin,
        .options,
    ]

    private var characters: [CharacterDisplay] {
        gameState.characterDisplays
    }

    private var selectedCharacterKey: String {
        gameState.selectedCharacterKey
    }

    private var selectedDisplay: CharacterDisplay? {
        characters.first { $0.key == selectedCharacterKey }
    }

    private var selectedCharacterName: String {
        selectedDisplay?.name.uppercased() ?? selectedCharacterKey.uppercased()
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                VersusHeaderView()

                Spacer(minLength: 8)

                mainCharacterView

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.rosterSpacing) {
                        ForEach(characters, id: \.key) { character in
                            rosterItem(character)
                        }
                    }
                    .padding(.horizontal, Layout.rosterHorizontalPadding)
                }

                Spacer()

                footerMenu
            }
        }
        .onAppear {
            gameState.loadCharactersIfNeeded()
        }
    }

    private var mainCharacterView: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.cyan.opacity(0.35),
                    .clear,
                ],
                center: .center,
                startRadius: 10,
                endRadius: 180
            )

            VStack(spacing: 10) {
                if let display = selectedDisplay {
                    Image(display.previewImage(using: gameState.wallet))
                        .resizable()
                        .scaledToFit()
                        .frame(height: Layout.mainPreviewHeight)
                        .scaleEffect(idlePulse ? 1.03 : 1.0)
                        .shadow(color: .cyan.opacity(0.35), radius: 30)
                        .shadow(color: .black.opacity(0.6), radius: 24)
                        .onAppear {
                            guard !idlePulse else { return }
                            idlePulse = true
                        }
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: idlePulse
                        )
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: Layout.placeholderHeight)
                }

                Text(selectedCharacterName)
                    .font(.system(size: 20, weight: .heavy))
                    .tracking(2)
                    .foregroundColor(.white)
                    .shadow(color: .cyan.opacity(0.6), radius: 12)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func rosterItem(_ character: CharacterDisplay) -> some View {
        let isSelected = character.key == selectedCharacterKey
        let isLocked = !isCharacterUnlocked(character)

        return Image(character.displayImage)
            .resizable()
            .scaledToFit()
            .frame(
                width: isSelected ? Layout.selectedRosterSize : Layout.rosterSize,
                height: isSelected ? Layout.selectedRosterSize : Layout.rosterSize
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.cyan : .clear, lineWidth: 3)
            )
            .opacity(isLocked ? 0.3 : 1)
            .onTapGesture {
                guard !isLocked else { return }
                withAnimation(.spring()) {
                    gameState.selectedCharacterKey = character.key
                }
            }
    }

    private var footerMenu: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items, id: \.self) { item in
                    footerItem(item)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.75),
                    Color.black.opacity(0.6),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func footerItem(_ item: HomeMenuItem) -> some View {
        let isUnlocked = isUnlocked(item)

        return Button {
            guard isUnlocked else { return }
            openMenuItem(item)
        } label: {
            Text(item.title.uppercased())
                .font(.system(size: 12, weight: .heavy))
                .tracking(1.5)
                .foregroundColor(isUnlocked ? .white : .gray)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            isUnlocked
                                ? item.color.opacity(0.25)
                                : Color.white.opacity(0.04)
                        )
                )
                .shadow(
                    color: isUnlocked ? item.color.opacity(0.35) : .clear,
                    radius: 8
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isUnlocked ? item.color.opacity(0.6) : .clear,
                            lineWidth: 1
                        )
                )
                .opacity(isUnlocked ? 1 : 0.45)
        }
        .buttonStyle(.plain)
    }

    private func isUnlocked(_ item: HomeMenuItem) -> Bool {
        guard item.requiredStorySectionId != nil else {
            return true
        }

        if item == .story {
            return true
        }

        return gameState.unlockedModes.contains(item.screen)
    }

    private func isCharacterUnlocked(_ character: CharacterDisplay) -> Bool {
        gameState.wallet?.unlockedCharacters.contains(character.key) == true
    }

    private func openMenuItem(_ item: HomeMenuItem) {
        if item == .versus {
            gameState.startQuickVersus()
            return
        }

        gameState.screen = item.screen
    }
}
