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
    @State private var showMenuOverlay = false

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

                Spacer(minLength: 8)

                mainCharacterView

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(characters, id: \.key) { character in
                            rosterItem(character)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                footerMenu
            }

            // ✅ HIER GEHÖRT DIE TRANSITION HIN
            if showMenuOverlay {
                menuOverlay
                    .zIndex(100)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom)
                                .combined(with: .opacity),
                            removal: .move(edge: .bottom)
                                .combined(with: .opacity)
                        )
                    )
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

    private func menuRow(_ item: HomeMenuItem) -> some View {
        let unlocked = isUnlocked(item)

        return Button {
            guard unlocked else { return }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                showMenuOverlay = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if item == .versus {
                    gameState.startQuickVersus()
                } else {
                    gameState.screen = item.screen
                }
            }

        } label: {
            HStack {
                Text(item.title.uppercased())
                    .font(.system(size: 14, weight: .heavy))
                    .tracking(1.5)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .opacity(0.6)
            }
            .foregroundColor(unlocked ? .white : .gray)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        unlocked
                            ? item.color.opacity(0.2)
                            : Color.white.opacity(0.05)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        unlocked ? item.color.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
            .opacity(unlocked ? 1 : 0.4)
        }
        .buttonStyle(.plain)
    }

    private var menuOverlay: some View {
        ZStack {

            // 🌑 BACKDROP
            LinearGradient(
                colors: [
                    Color.blue,
                    Color.indigo,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                    showMenuOverlay = false
                }
            }

            // 📋 MENU SHEET
            VStack(spacing: 0) {

                // 🔽 Handle
                Capsule()
                    .fill(Color.white)
                    .frame(width: 40, height: 5)
                    .padding(.vertical, 10)

                // 📜 SCROLLABLE CONTENT
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            menuRow(item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: min(CGFloat(items.count) * 64 + 60, 420))
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.95))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
        .mask(
            LinearGradient(
                colors: [.clear, .black, .black, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var selectedDisplay: CharacterDisplay? {
        characters.first { $0.key == gameState.selectedCharacterKey }
    }

    private var mainCharacterView: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.30),
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
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                showMenuOverlay.toggle()
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue,
                                Color.black,
                                Color.blue,
                            ],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: .cyan.opacity(0.6), radius: 20)

                Image(systemName: "circle.circle")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .transition(
            .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        )
        .frame(height: 160)
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
