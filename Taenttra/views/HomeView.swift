//
//  HomeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState

    @State private var selection: Int = 0

    // Ordered list of menu items used by the menu and confirmSelection
    private let items: [HomeMenuItem] = [
        .story,
        .events,
        .training,
        .arcade,
        .survival,
        .versus,
        .shop,
        .skin,
        .leaderboard,
        .options,
    ]

    private let characters: [CharacterDisplay] = loadCharacterDisplays()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                
                VersusHeaderView()

                Spacer(minLength: 8)

                mainCharacterView

                characterRoster

                Spacer()

                footerMenu
            }
        }
    }

    private var mainCharacterView: some View {
        ZStack {
            RadialGradient(
                colors: [.cyan.opacity(0.25), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 220
            )

            VStack(spacing: 10) {
                if let display = characters.first(where: {
                    $0.key == gameState.selectedCharacterKey
                }) {
                    Image(display.previewImage(using: gameState.wallet))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 260)
                        .shadow(color: Color.black.opacity(0.6), radius: 24)
                } else {
                    // Placeholder when no character matches
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 260)
                }

                Text(gameState.selectedCharacterName.uppercased())
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var characterRoster: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(characters) { character in
                    rosterItem(character)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func rosterItem(_ character: CharacterDisplay) -> some View {
        let isSelected = character.key == gameState.selectedCharacterKey
        let locked = !gameState.wallet!.unlockedCharacters.contains(
            character.key
        )

        return Image(character.displayImage)
            .resizable()
            .scaledToFit()
            .frame(width: isSelected ? 68 : 56, height: isSelected ? 68 : 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 3)
            )
            .opacity(locked ? 0.3 : 1)
            .onTapGesture {
                guard !locked else { return }
                withAnimation(.spring()) {
                    gameState.selectedCharacterKey = character.key
                }
            }
    }

    private func footerButton(
        _ title: String,
        _ icon: String,
        _ screen: GameScreen
    ) -> some View {
        Button {
            gameState.screen = screen
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)

                Text(title)
                    .font(.caption.weight(.bold))
            }
            .foregroundColor(.white)
            .frame(width: 72)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
            )
        }
    }

    private var footerMenu: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items, id: \.self) { item in
                    footerItem(item)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(.ultraThinMaterial)
    }

    private func footerItem(_ item: HomeMenuItem) -> some View {
        let unlocked = isUnlocked(item)

        return Button {
            guard unlocked else { return }

            if item == .versus {
                gameState.pendingMode = .versus
                gameState.screen = .characterSelect
            } else {
                gameState.screen = item.screen
            }
        } label: {
            Text(item.title)
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(unlocked ? .white : .gray)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            unlocked
                            ? item.color.opacity(0.35)
                            : Color.white.opacity(0.06)
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            unlocked
                            ? item.color.opacity(0.6)
                            : Color.clear,
                            lineWidth: 1
                        )
                )
                .opacity(unlocked ? 1 : 0.45)
        }
        .buttonStyle(.plain)
    }


    // MARK: - Menu Item
    private func menuItem(
        item: HomeMenuItem,
        index: Int
    ) -> some View {

        let isSelected = selection == index
        let unlocked = isUnlocked(item)

        return HStack(spacing: 16) {

            // 🔹 Indicator
            Circle()
                .fill(unlocked ? item.color : .gray)
                .frame(width: 10, height: 10)
                .opacity(isSelected ? 1 : 0.4)

            // 📝 Title
            Text(item.title)
                .font(
                    .system(size: 18, weight: isSelected ? .semibold : .regular)
                )
                .foregroundStyle(
                    unlocked
                        ? (isSelected ? item.color : .primary)
                        : .secondary
                )

            Spacer()

            // 🔒 / ➜
            if unlocked {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(isSelected ? item.color : .secondary)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isSelected
                        ? item.color.opacity(0.14)
                        : Color.secondary.opacity(0.06)
                )
        }
        .overlay {
            if !unlocked {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.15))
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture {
            selection = index
        }
    }

    // MARK: - Unlock Logic
    private func isUnlocked(_ item: HomeMenuItem) -> Bool {
        // Immer frei, wenn keine Story-Bedingung existiert
        guard item.requiredStorySectionId != nil else {
            return true
        }

        // Story selbst ist immer spielbar
        if item == .story {
            return true
        }

        // Modus ist freigeschaltet, wenn er bereits in unlockedModes ist
        return gameState.unlockedModes.contains(item.screen)
    }

    private func lockedReason(for item: HomeMenuItem) -> String {
        guard let required = item.requiredStorySectionId else {
            return "🔒 Modus gesperrt"
        }

        if gameState.lastCompletedStorySectionId != nil {
            return "📖 Schließe Story Abschnitt \(required) ab"
        } else {
            return "📖 Starte zuerst die Story"
        }
    }

    // MARK: - Navigation
    private func confirmSelection() {
        let item = items[selection]

        guard isUnlocked(item) else {
            gameState.unlockMessage = "📖 Schließe erst die Story ab"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                gameState.unlockMessage = nil
            }
            return
        }

        switch item {
        case .story:
            gameState.screen = .story
        case .events:
            gameState.screen = .events
        case .training:
            gameState.screen = .training
        case .arcade:
            gameState.screen = .arcade
        case .survival:
            gameState.screen = .survival
        case .versus:
            gameState.pendingMode = .versus
            gameState.screen = .characterSelect
        case .shop:
            gameState.screen = .shop
        case .skin:
            gameState.screen = .skin
        case .leaderboard:
            gameState.screen = .leaderboard
        case .options:
            gameState.screen = .options
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
}
