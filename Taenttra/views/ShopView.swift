//
//  ShopView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftData
import SwiftUI

struct ShopView: View {

    @EnvironmentObject var gameState: GameState
    private let data = ShopLoader.load()

    @State private var selectedCategoryIndex: Int = 0

    // MARK: - Derived State

    private var categories: [ShopCategory] {
        data.categories
    }

    private var selectedCategory: ShopCategory? {
        guard categories.indices.contains(selectedCategoryIndex) else {
            return categories.first
        }
        return categories[selectedCategoryIndex]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.black.ignoresSafeArea()

            // ⬅️ BACK
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            if let wallet = gameState.wallet {
                content(wallet: wallet)
                    .padding(.top, 48)  // 🔥 Platz für Button
            } else {
                ProgressView("Loading Shop…")
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Content
    private func content(wallet: PlayerWallet) -> some View {
        VStack(spacing: 12) {
            VersusHeaderView()

            if !categories.isEmpty {
                categoryTabs
            }

            if selectedCategory?.id == "event_skins" {
                Text(
                    "Event Skins can only be unlocked by winning Tournaments 🏆"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }

            if let category = selectedCategory {
                shopCards(category: category, wallet: wallet)
            } else {
                emptyState
            }

            Spacer()
        }
    }

    private func shopCards(
        category: ShopCategory,
        wallet: PlayerWallet
    ) -> some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(category.items) { item in
                    shopCard(item, wallet: wallet)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func shopCard(
        _ item: ShopItem,
        wallet: PlayerWallet
    ) -> some View {
        let isEventItem = item.currency == .tournamentShards

        let canAfford: Bool = {
            switch item.currency {
            case .coins:
                return wallet.coins >= item.price
            case .crystals:
                return wallet.crystals >= item.price
            case .tournamentShards:
                return wallet.tournamentShards >= item.price
            }
        }()

        return VStack(spacing: 14) {

            // 🖼️ Preview
            ZStack(alignment: .topTrailing) {
                Image(item.preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.black)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        isEventItem
                                            ? LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            : LinearGradient(
                                                colors: [
                                                    Color.cyan.opacity(0.8),
                                                    Color.cyan.opacity(0.8),
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                        lineWidth: isEventItem ? 3 : 2
                                    )
                            }
                            .shadow(
                                color: isEventItem
                                    ? Color.yellow.opacity(0.4)
                                    : Color.cyan.opacity(0.35),
                                radius: isEventItem ? 18 : 12,
                                y: isEventItem ? 8 : 4
                            )
                    )

                Text(isEventItem ? "EVENT" : "ITEM")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isEventItem ? Color.yellow : Color.cyan)
                    )
                    .foregroundColor(.black)
                    .padding(8)
            }

            // 🏷️ Name
            VStack(spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if wallet.ownedSkins.contains(item.skinId) {
                    Text(
                        wallet.equippedSkin == item.skinId
                            ? "EQUIPPED"
                            : "OWNED"
                    )
                    .font(.caption2.weight(.bold))
                    .foregroundColor(
                        wallet.equippedSkin == item.skinId
                            ? .cyan
                            : .secondary
                    )
                }
            }

            // 💰 Price
            HStack(spacing: 6) {
                Image(currencyIcon(for: item.currency))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)

                Text("\(item.price)")
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                isEventItem
                                    ? Color.yellow.opacity(0.4)
                                    : Color.cyan.opacity(0.25),
                                lineWidth: 1
                            )
                    )
            )
            .overlay {
                if isEventItem {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow, lineWidth: 2)
                }
            }
            .shadow(
                color: isEventItem ? Color.yellow.opacity(0.3) : .clear,
                radius: isEventItem ? 10 : 0,
                y: isEventItem ? 4 : 0
            )

            // 🛒 Buy Button
            Button {
                withAnimation {
                    guard canAfford else { return }

                    switch item.currency {
                    case .coins:
                        wallet.coins -= item.price
                    case .crystals:
                        wallet.crystals -= item.price
                    case .tournamentShards:
                        wallet.tournamentShards -= item.price
                    }

                    if !wallet.ownedSkins.contains(item.skinId) {
                        wallet.ownedSkins.append(item.skinId)
                    }
                }

            } label: {
                Text(canAfford ? "BUY" : "NOT ENOUGH")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                canAfford
                                    ? (isEventItem ? Color.yellow : Color.cyan)
                                    : Color.gray.opacity(0.25)
                            )
                    )
                    .foregroundColor(.black)
            }
            .disabled(!canAfford)
        }
        .frame(width: 220)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.black))
        )
    }

    private func currencyIcon(for currency: Currency) -> String {
        switch currency {
        case .coins: return "icon_coin"
        case .crystals: return "icon_crystal"
        case .tournamentShards: return "icon_tournament"
        }
    }

    // MARK: - Tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(categories.enumerated()), id: \.element.id) {
                    index,
                    category in
                    tabButton(
                        category: category,
                        isSelected: index == selectedCategoryIndex
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategoryIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Tab Button

    private func tabButton(
        category: ShopCategory,
        isSelected: Bool
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.caption)

            Text(category.title)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(isSelected ? .primary : .secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isSelected ? Color(.secondarySystemBackground) : .clear)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Text("Shop is empty")
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.top, 40)
    }
}

#Preview {
    let gs = GameState()
    gs.wallet = PlayerWallet(coins: 2500, crystals: 25)

    return NavigationStack {
        ShopView()
            .environmentObject(gs)
    }
}
