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
    @State private var idlePulse = false

    // Ordered list of menu items used by the menu and confirmSelection
    private let items: [HomeMenuItem] = [
        .story,
        .events,
        .training,
        .arcade,
        .survival,
        .versus,
        .leaderboard,
        .shop,
        .skin,
        .news,
        .options,
    ]

    // Character displays for the roster and main preview
    private var characters: [CharacterDisplay] {
        gameState.characterDisplays
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                VersusHeaderView()

                Spacer(minLength: 8)

                mainCharacterView

                // Roster strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(characters, id: \.key) { character in
                            rosterItem(character)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Spacer()

                footerMenu
            }
        }
        .onAppear {
            gameState.loadCharactersIfNeeded()
        }
        .onAppear {
            if let index = items.firstIndex(of: .story) {
                selection = index
            }
        }
    }

    private var selectedDisplay: CharacterDisplay? {
        characters.first { $0.key == gameState.selectedCharacterKey }
    }

    private var mainCharacterView: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.cyan.opacity(0.35),
                    Color.clear,
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
                        .frame(height: 270)
                        .scaleEffect(idlePulse ? 1.03 : 1.0)
                        .shadow(color: .cyan.opacity(0.35), radius: 30)
                        .shadow(color: .black.opacity(0.6), radius: 24)
                        .onAppear {
                            guard !idlePulse else { return }
                            idlePulse = true
                        }
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(
                                autoreverses: true
                            ),
                            value: idlePulse
                        )
                } else {
                    // Placeholder when no character matches
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 260)
                }

                Text(
                    selectedDisplay?.name.uppercased()
                        ?? gameState.selectedCharacterKey.uppercased()
                )
                .font(.system(size: 20, weight: .heavy))
                .tracking(2)
                .foregroundColor(.white)
                .shadow(color: .cyan.opacity(0.6), radius: 12)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func rosterItem(_ character: CharacterDisplay) -> some View {
        let isSelected = character.key == gameState.selectedCharacterKey
        let locked =
            !(gameState.wallet?.unlockedCharacters.contains(character.key)
            ?? false)

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
        ZStack {
            if let prev = item(at: selection - 1) {
                carouselButton(
                    for: prev,
                    offset: -110,
                    scale: 0.8,
                    opacity: 0.5,
                    z: 0
                )
            }

            carouselButton(
                for: items[selection],
                offset: 0,
                scale: 1.15,
                opacity: 1,
                z: 2
            )

            if let next = item(at: selection + 1) {
                carouselButton(
                    for: next,
                    offset: 110,
                    scale: 0.8,
                    opacity: 0.5,
                    z: 1
                )
            }
        }
        .frame(height: 180)
        .gesture(dragGesture)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.8),
            value: selection
        )
    }

    private func carouselButton(
        for item: HomeMenuItem,
        offset: CGFloat,
        scale: CGFloat,
        opacity: Double,
        z: Double
    ) -> some View {

        Button {
            if item == .versus {
                gameState.startQuickVersus()
            } else {
                gameState.screen = item.screen
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                item.color.opacity(0.85),
                                item.color.opacity(0.3),
                            ],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: item.color.opacity(0.6), radius: 20)

                Text(item.title.prefix(1))
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(.black.opacity(0.85))
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(x: offset)
        .zIndex(z)
        .buttonStyle(.plain)
    }

    private func item(at index: Int) -> HomeMenuItem? {
        let count = items.count
        let wrapped = (index + count) % count
        return items[wrapped]
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width < -40 {
                    selection = (selection + 1) % items.count
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else if value.translation.width > 40 {
                    selection = (selection - 1 + items.count) % items.count
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
    }

    private func footerItem(_ item: HomeMenuItem) -> some View {
        let unlocked = isUnlocked(item)

        return Button {
            guard unlocked else { return }

            if item == .versus {
                gameState.startQuickVersus()
            } else {
                gameState.screen = item.screen
            }
        } label: {
            Text(item.title.uppercased())
                .font(.system(size: 12, weight: .heavy))
                .tracking(1.5)
                .foregroundColor(unlocked ? .white : .gray)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            unlocked
                                ? item.color.opacity(0.25)
                                : Color.white.opacity(0.04)
                        )
                )
                .shadow(
                    color: unlocked ? item.color.opacity(0.35) : .clear,
                    radius: 8
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
        case .news:
            gameState.screen = .news
        case .options:
            gameState.screen = .options
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
}
