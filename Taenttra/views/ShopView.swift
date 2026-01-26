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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if let wallet = gameState.wallet {
                content(wallet: wallet)
            } else {
                ProgressView("Loading Shop…")
            }
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Content
    private func content(wallet: PlayerWallet) -> some View {
        VStack(spacing: 12) {
            VersusHeaderView()

            if !categories.isEmpty {
                categoryTabs
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

        let canAfford = wallet.coins >= item.price

        return VStack(spacing: 14) {

            // 🖼️ Preview
            Image(item.preview)
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemBackground))
                )

            // 🏷️ Name
            Text(item.name)
                .font(.headline)
                .multilineTextAlignment(.center)

            // 💰 Price
            HStack(spacing: 8) {
                CoinPriceView(value: item.price)

            }

            // 🛒 Buy Button
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if wallet.coins >= item.price {
                        wallet.coins -= item.price
                        if !wallet.ownedSkins.contains(item.skinId) {
                            wallet.ownedSkins.append(item.skinId)
                        }
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
                                canAfford ? Color.cyan : Color.gray.opacity(0.3)
                            )
                    )
                    .foregroundColor(.black)
            }
            .disabled(!canAfford)
        }
        .frame(width: 220)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.secondarySystemBackground))
        )
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
