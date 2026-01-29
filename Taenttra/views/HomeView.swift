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
    private let items = HomeMenuItem.allCases

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                VersusHeaderView()

                // MARK: - Scrollable Menu
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(items.indices, id: \.self) { index in
                            menuItem(
                                item: items[index],
                                index: index
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                Spacer()

                // 🔥 CONFIRM
                Text(
                    isUnlocked(items[selection])
                        ? "START \(items[selection].title.uppercased())"
                        : lockedReason(for: items[selection])
                )
                .font(.caption.bold())
                .foregroundStyle(
                    isUnlocked(items[selection])
                        ? items[selection].color
                        : .secondary
                )
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.15), value: selection)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.primary.opacity(0.06))
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .onTapGesture {
                    confirmSelection()
                }
            }
        }
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
