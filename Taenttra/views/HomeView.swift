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

                Text("TAENTTRA")
                    .font(.largeTitle.weight(.semibold))
                    .padding(.top, 4)

                // MARK: - Scrollable Menu
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(items.indices, id: \.self) { index in
                            menuItem(
                                item: items[index],
                                index: index
                            )
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()

                // 🔥 CONFIRM
                Text("TAP TO CONFIRM")
                    .padding(.bottom, 12)
                    .onTapGesture {
                        confirmSelection()
                    }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Menu Item
    private func menuItem(
        item: HomeMenuItem,
        index: Int
    ) -> some View {

        let isSelected = selection == index
        let unlocked = isUnlocked(item)

        return HStack(spacing: 14) {

            Rectangle()
                .fill(isSelected ? item.color : item.color.opacity(0.3))
                .frame(width: 10, height: 10)
                .cornerRadius(2)

            Text(item.title)
                .font(.title3.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(
                    unlocked
                    ? (isSelected ? item.color : .primary)
                    : .secondary
                )
                .opacity(unlocked ? (isSelected ? 1 : 0.35) : 0.25)

            Spacer()

            if !unlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 24)
        .background(
            isSelected
                ? item.color.opacity(0.12)
                : Color.clear
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.16), value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture {
            guard unlocked else { return }
            selection = index
        }
    }


    // MARK: - Unlock Logic
    private func isUnlocked(_ item: HomeMenuItem) -> Bool {
        if !item.requiresUnlock {
            return true
        }
        return gameState.unlockedModes.contains(item.screen)
    }
    
    // MARK: - Navigation
    private func confirmSelection() {
        let item = items[selection]

        guard isUnlocked(item) else {
            gameState.unlockMessage = "🔒 Modus noch gesperrt"
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
