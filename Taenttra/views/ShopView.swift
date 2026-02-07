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

    @State private var selectedTab: ShopTab?

    private var allItems: [ShopItem] {
        data.categories.flatMap { $0.items }
    }

    private var tabs: [ShopTab] {
        let order: [Currency] = [.coins, .crystals, .tournamentShards]

        return order.compactMap { currency in
            allItems.contains(where: { $0.currency == currency })
                ? ShopTab(
                    currency: currency,
                    title: title(for: currency),
                    icon: icon(for: currency)
                )
                : nil
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.black.ignoresSafeArea()

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            if let wallet = gameState.wallet {
                content(wallet: wallet)
                    .padding(.top, 48)
            } else {
                ProgressView("Loading Shop…")
                    .foregroundColor(.white)
            }
        }
    }

    private func shopCards(wallet: PlayerWallet) -> some View {
        if filteredItems.isEmpty {
            return AnyView(emptyState)
        } else {
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(filteredItems) { item in
                            shopCard(item, wallet: wallet)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .id(selectedTab?.currency)
            )
        }
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(tab.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)

                            Text(tab.title)
                                .font(.caption2.weight(.semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    selectedTab?.currency == tab.currency
                                        ? Color.white.opacity(0.12)
                                        : Color.clear
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    Color.white.opacity(
                                        selectedTab?.currency == tab.currency
                                            ? 0 : 0.25
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .foregroundColor(
                            selectedTab?.currency == tab.currency
                                ? .white
                                : .white.opacity(0.7)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Content
    private func content(wallet: PlayerWallet) -> some View {
        VStack(spacing: 12) {
            HeaderView()

            if !tabs.isEmpty {
                categoryTabs
            }

            shopCards(wallet: wallet)

            Spacer()
        }
        .onAppear {
            if selectedTab == nil
                || !tabs.contains(where: {
                    $0.currency == selectedTab?.currency
                })
            {
                selectedTab = tabs.first
            }
        }
        .onChange(of: selectedTab) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private var filteredItems: [ShopItem] {
        guard let tab = selectedTab else { return [] }

        return
            allItems
            .filter { $0.currency == tab.currency }
            .sorted {
                let ownedA =
                    gameState.wallet?.ownedSkins.contains($0.skinId) ?? false
                let ownedB =
                    gameState.wallet?.ownedSkins.contains($1.skinId) ?? false
                return ownedA && !ownedB
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        isEventItem
                                            ? Color.yellow.opacity(0.5)
                                            : Color.cyan.opacity(0.4),
                                        lineWidth: 1
                                    )
                            )
                            .overlay(alignment: .topTrailing) {
                                let badgeText =
                                    item.price == 0
                                    ? "FREE" : (isEventItem ? "EVENT" : "ITEM")
                                let badgeColor: Color =
                                    item.price == 0
                                    ? .green : (isEventItem ? .yellow : .cyan)
                                Text(badgeText)
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(badgeColor))
                                    .foregroundColor(.black)
                                    .padding(8)
                            }
                            .shadow(
                                color: isEventItem
                                    ? Color.yellow.opacity(0.4)
                                    : Color.cyan.opacity(0.35),
                                radius: isEventItem ? 18 : 12,
                                y: isEventItem ? 8 : 4
                            )
                    )
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

    private func title(for currency: Currency) -> String {
        switch currency {
        case .coins: return "Coins"
        case .crystals: return "Crystals"
        case .tournamentShards: return "Event"
        }
    }

    private func icon(for currency: Currency) -> String {
        switch currency {
        case .coins: return "icon_coin"
        case .crystals: return "icon_crystal"
        case .tournamentShards: return "icon_tournament"
        }
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
