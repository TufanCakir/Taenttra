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
    @Query private var wallets: [PlayerWallet]
    @Environment(\.modelContext) private var modelContext

    let data = ShopLoader.load()
    @State private var selectedCategoryIndex = 0

    private var wallet: PlayerWallet {
        if let w = wallets.first {
            return w
        }

        let w = PlayerWallet()
        modelContext.insert(w)
        return w
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(data.categories.indices, id: \.self) { index in
                            tabButton(
                                category: data.categories[index],
                                isSelected: selectedCategoryIndex == index
                            )
                            .onTapGesture {
                                selectedCategoryIndex = index
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(.ultraThinMaterial)

                Divider()

                // MARK: - Items
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(data.categories[selectedCategoryIndex].items) {
                            item in
                            ShopItemRow(item: item, wallet: wallet)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Tab Button
    private func tabButton(category: ShopCategory, isSelected: Bool)
        -> some View
    {
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
                .fill(
                    isSelected
                        ? Color(.secondarySystemBackground)
                        : Color.clear
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    ShopView()
        .environmentObject(GameState())
}
