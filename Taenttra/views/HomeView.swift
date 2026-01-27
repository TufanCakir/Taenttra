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
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            confirmSelection()
                        }
                    )
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

        return HStack(spacing: 14) {

            Rectangle()
                .fill(isSelected ? item.color : item.color.opacity(0.3))
                .frame(width: 10, height: 10)
                .cornerRadius(2)

            Text(item.title)
                .font(.title3.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? item.color : .primary)
                .opacity(isSelected ? 1 : 0.45)

            Spacer()
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
            selection = index
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Navigation
    private func confirmSelection() {
        let selectedItem = items[selection]

        switch selectedItem {

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
