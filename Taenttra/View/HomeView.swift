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
        static let rosterHorizontalPadding: CGFloat = 20
        static let selectedRosterSize: CGFloat = 76
        static let rosterSize: CGFloat = 58
        static let heroImageHeight: CGFloat = 300
        static let heroOrbSize: CGFloat = 292
        static let ctaOrbSize: CGFloat = 156
    }

    @EnvironmentObject var gameState: GameState

    @State private var idlePulse = false
    @State private var selectedMenuIndex = 5

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

    private var selectedMenuItem: HomeMenuItem {
        items[selectedMenuIndex]
    }

    private var selectedMenuUnlocked: Bool {
        isUnlocked(selectedMenuItem)
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                topHeader

                Spacer(minLength: 8)

                heroSection

                modeSelector

                rosterStrip

                Spacer(minLength: 14)

                bottomDock
            }
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .onAppear {
            gameState.loadCharactersIfNeeded()
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.01, blue: 0.18),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 32)
                .offset(x: -110, y: -230)

            Circle()
                .fill(selectedMenuItem.color.opacity(0.18))
                .frame(width: 360, height: 360)
                .blur(radius: 38)
                .offset(x: 130, y: 140)

            AngularGradient(
                colors: [
                    .clear,
                    .white.opacity(0.12),
                    .clear,
                    selectedMenuItem.color.opacity(0.16),
                    .clear,
                ],
                center: .center
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }

    private var topHeader: some View {
        VStack(spacing: 10) {
            VersusHeaderView()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TAENTTRA")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.white)

                    Text("BATTLE LOBBY")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(selectedMenuItem.color.opacity(0.9))
                }

                Spacer()

                statusChip(
                    title: selectedMenuUnlocked ? "READY" : "LOCKED",
                    color: selectedMenuUnlocked ? .green : .orange
                )
            }
            .padding(.horizontal, 20)
        }
    }

    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            selectedMenuItem.color.opacity(0.45),
                            Color.white.opacity(0.16),
                            Color.black.opacity(0.92),
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 170
                    )
                )
                .frame(width: Layout.heroOrbSize, height: Layout.heroOrbSize)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.22), lineWidth: 7)
                        .blur(radius: 1)
                )
                .overlay(
                    Circle()
                        .stroke(selectedMenuItem.color.opacity(0.65), lineWidth: 2)
                        .padding(12)
                )
                .shadow(color: selectedMenuItem.color.opacity(0.4), radius: 22)

            if let display = selectedDisplay {
                Image(display.previewImage(using: gameState.wallet))
                    .resizable()
                    .scaledToFit()
                    .frame(height: Layout.heroImageHeight)
                    .scaleEffect(idlePulse ? 1.035 : 0.995)
                    .shadow(color: .white.opacity(0.16), radius: 8)
                    .shadow(color: selectedMenuItem.color.opacity(0.35), radius: 28)
                    .offset(y: -8)
                    .onAppear {
                        guard !idlePulse else { return }
                        idlePulse = true
                    }
                    .animation(
                        .easeInOut(duration: 2.4).repeatForever(autoreverses: true),
                        value: idlePulse
                    )
            }

            VStack {
                HStack {
                    badge("POWER", value: "S")
                    Spacer()
                    badge("MODE", value: selectedMenuItem.title.uppercased())
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                Spacer()

                VStack(spacing: 4) {
                    Text(selectedCharacterName)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white)

                    Text(modeCaption)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(2.2)
                        .foregroundStyle(selectedMenuItem.color.opacity(0.92))
                }
                .padding(.bottom, 20)
            }
            .frame(width: Layout.heroOrbSize, height: Layout.heroOrbSize)
        }
        .padding(.top, 8)
    }

    private var modeSelector: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                cycleButton(systemName: "chevron.left", direction: -1)

                Button {
                    triggerSelectedMenu()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        selectedMenuItem.color.opacity(0.95),
                                        selectedMenuItem.color.opacity(0.5),
                                    ],
                                    center: .center,
                                    startRadius: 6,
                                    endRadius: 90
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.45), lineWidth: 4)
                            )
                            .shadow(color: selectedMenuItem.color.opacity(0.6), radius: 16)

                        VStack(spacing: 6) {
                            Text(selectedMenuItem.title.uppercased())
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.6)
                                .foregroundStyle(.black.opacity(0.88))

                            Text(selectedMenuUnlocked ? "TAP TO ENTER" : "STORY REQUIRED")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1.4)
                                .foregroundStyle(.black.opacity(0.72))
                        }
                        .padding(.horizontal, 10)
                    }
                    .frame(width: Layout.ctaOrbSize, height: Layout.ctaOrbSize)
                }
                .buttonStyle(.plain)

                cycleButton(systemName: "chevron.right", direction: 1)
            }

            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Capsule()
                        .fill(index == selectedMenuIndex ? item.color : Color.white.opacity(0.18))
                        .frame(width: index == selectedMenuIndex ? 22 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: selectedMenuIndex)
                }
            }
        }
        .padding(.top, 6)
    }

    private var rosterStrip: some View {
        VStack(spacing: 10) {
            HStack {
                Text("ROSTER")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.65))

                Spacer()
            }
            .padding(.horizontal, Layout.rosterHorizontalPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Layout.rosterSpacing) {
                    ForEach(characters, id: \.key) { character in
                        rosterItem(character)
                    }
                }
                .padding(.horizontal, Layout.rosterHorizontalPadding)
            }
        }
        .padding(.top, 12)
    }

    private func rosterItem(_ character: CharacterDisplay) -> some View {
        let isSelected = character.key == selectedCharacterKey
        let isLocked = !isCharacterUnlocked(character)

        return ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isSelected ? 0.18 : 0.08),
                            Color.black.opacity(0.8),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Image(character.displayImage)
                .resizable()
                .scaledToFit()
                .padding(8)
                .opacity(isLocked ? 0.25 : 1)

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(Color.black.opacity(0.7)))
                    .padding(.bottom, 6)
            }
        }
        .frame(
            width: isSelected ? Layout.selectedRosterSize : Layout.rosterSize,
            height: isSelected ? Layout.selectedRosterSize + 8 : Layout.rosterSize + 6
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isSelected ? selectedMenuItem.color : Color.white.opacity(0.08),
                    lineWidth: isSelected ? 3 : 1
                )
        )
        .shadow(color: isSelected ? selectedMenuItem.color.opacity(0.35) : .clear, radius: 12)
        .scaleEffect(isSelected ? 1.04 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: selectedCharacterKey)
        .onTapGesture {
            guard !isLocked else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                gameState.selectedCharacterKey = character.key
            }
        }
    }

    private var bottomDock: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    bottomDockItem(item, index: index)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.black.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
    }

    private func bottomDockItem(_ item: HomeMenuItem, index: Int) -> some View {
        let unlocked = isUnlocked(item)
        let selected = index == selectedMenuIndex

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMenuIndex = index
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(selected ? item.color.opacity(0.95) : Color.white.opacity(0.08))
                        .frame(width: 42, height: 42)

                    Image(systemName: iconName(for: item))
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(selected ? .black : unlocked ? .white : .gray)
                }

                Text(item.title)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .foregroundStyle(unlocked ? .white : .gray)
            }
            .frame(maxWidth: .infinity)
            .opacity(unlocked ? 1 : 0.45)
        }
        .buttonStyle(.plain)
    }

    private func cycleButton(systemName: String, direction: Int) -> some View {
        Button {
            cycleMenu(by: direction)
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func badge(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.58))

            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.55))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func statusChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.8)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color.opacity(0.24))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.55), lineWidth: 1)
                    )
            )
    }

    private var modeCaption: String {
        if selectedMenuUnlocked {
            return "SELECT MODE • ENTER MATCH"
        }

        return "CLEAR STORY TO UNLOCK"
    }

    private func cycleMenu(by direction: Int) {
        let nextIndex = (selectedMenuIndex + direction + items.count) % items.count
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedMenuIndex = nextIndex
        }
    }

    private func triggerSelectedMenu() {
        guard selectedMenuUnlocked else {
            showLockedMessage(for: selectedMenuItem)
            return
        }

        openMenuItem(selectedMenuItem)
    }

    private func showLockedMessage(for item: HomeMenuItem) {
        let required = item.requiredStorySectionId ?? "Story"
        gameState.unlockMessage = "Finish \(required) to unlock \(item.title)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if gameState.unlockMessage == "Finish \(required) to unlock \(item.title)" {
                gameState.unlockMessage = nil
            }
        }
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

    private func iconName(for item: HomeMenuItem) -> String {
        switch item {
        case .story:
            return "book.fill"
        case .events:
            return "sparkles"
        case .training:
            return "figure.boxing"
        case .arcade:
            return "gamecontroller.fill"
        case .survival:
            return "flame.fill"
        case .versus:
            return "bolt.fill"
        case .shop:
            return "cart.fill"
        case .summon:
            return "sparkles.rectangle.stack.fill"
        case .skin:
            return "paintpalette.fill"
        case .options:
            return "gearshape.fill"
        }
    }
}
