//
//  ShopView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import StoreKit
import SwiftData
import SwiftUI

struct ShopView: View {
    private enum Layout {
        static let cardWidth: CGFloat = 220
    }

    @EnvironmentObject var gameState: GameState

    private let data = ShopLoader.load()

    @StateObject private var store = StoreService.shared
    @State private var selectedTab: ShopTab?

    private var allItems: [ShopItem] {
        data.categories.flatMap(\.items)
    }

    private var tabs: [ShopTab] {
        let order: [Currency] = [.coins, .crystals, .shards, .realMoney]

        return order.compactMap { currency in
            guard allItems.contains(where: { $0.currency == currency }) else {
                return nil
            }

            return ShopTab(
                currency: currency,
                title: title(for: currency),
                icon: icon(for: currency)
            )
        }
    }

    private var filteredItems: [ShopItem] {
        guard let selectedCurrency = selectedTab?.currency else {
            return []
        }

        return allItems
            .filter { $0.currency == selectedCurrency }
            .sorted { lhs, rhs in
                let lhsOwned = isOwned(lhs)
                let rhsOwned = isOwned(rhs)

                if lhsOwned != rhsOwned {
                    return lhsOwned && !rhsOwned
                }

                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
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
                    .foregroundStyle(.white)
            }
        }
        .task {
            ensureSelectedTab()

            let ids = Set(allItems.compactMap(\.productId))
            guard !ids.isEmpty else { return }

            await store.loadProducts(ids: Array(ids))
        }
        .onChange(of: tabs) { _, _ in
            ensureSelectedTab()
        }
    }

    private func content(wallet: PlayerWallet) -> some View {
        VStack(spacing: 12) {
            VersusHeaderView()

            if !tabs.isEmpty {
                categoryTabs
            }

            shopCards(wallet: wallet)

            if let errorMessage = store.lastErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
        .onAppear {
            ensureSelectedTab()
        }
        .onChange(of: selectedTab) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func shopCards(wallet: PlayerWallet) -> some View {
        Group {
            if filteredItems.isEmpty {
                emptyState
            } else {
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
            }
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
                                        : .clear
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    Color.white.opacity(
                                        selectedTab?.currency == tab.currency ? 0 : 0.25
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .foregroundStyle(
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

    private func shopCard(_ item: ShopItem, wallet: PlayerWallet) -> some View {
        let isEventItem = item.currency == .shards
        let isStoreItem = item.productId != nil
        let owned = isOwned(item)
        let equipped = isEquipped(item)
        let buttonState = buttonState(for: item, wallet: wallet)

        return VStack(spacing: 14) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 6) {
                    Image(item.preview)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)

                    if let amount = item.amount {
                        Text("+\(amount)")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(.white)

                        Text(amountLabel(for: item))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(highlightColor(for: item))
                            .tracking(1.2)
                    }
                }
                .frame(height: 140)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(cardBorderColor(for: item), lineWidth: 1)
                        )
                )

                Text(badgeText(for: item))
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(highlightColor(for: item)))
                    .foregroundStyle(.black)
                    .padding(8)
            }

            VStack(spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if item.type == .skin, owned {
                    Text(equipped ? "Equipped" : "Owned")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(equipped ? Color.cyan : .secondary)
                }
            }

            HStack(spacing: 6) {
                Image(currencyIcon(for: item.currency))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)

                Text(priceText(for: item))
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
                            .stroke(cardBorderColor(for: item), lineWidth: 1)
                    )
            )
            .overlay {
                if isEventItem {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.yellow, lineWidth: 2)
                }
            }
            .shadow(
                color: isEventItem ? Color.yellow.opacity(0.3) : .clear,
                radius: isEventItem ? 10 : 0,
                y: isEventItem ? 4 : 0
            )

            Button {
                store.clearError()
                if isStoreItem {
                    buyWithStoreKit(item)
                } else {
                    buyWithGameCurrency(item, wallet: wallet)
                }
            } label: {
                Text(buttonState.title)
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(buttonState.backgroundColor)
                    )
                    .foregroundStyle(.black)
            }
            .disabled(buttonState.isDisabled)
        }
        .frame(width: Layout.cardWidth)
    }

    private func buyWithStoreKit(_ item: ShopItem) {
        guard
            let product = store.product(for: item.productId),
            let wallet = gameState.wallet
        else {
            return
        }

        Task {
            let success = await store.purchase(product: product)
            guard success else { return }

            switch item.type {
            case .currency:
                if let amount = item.amount {
                    wallet.crystals += amount
                }
            case .skin:
                applyOwnedSkin(for: item, wallet: wallet)
            }
        }
    }

    private func buyWithGameCurrency(_ item: ShopItem, wallet: PlayerWallet) {
        guard canAfford(item, wallet: wallet) else { return }

        switch item.type {
        case .skin:
            guard let skin = skinItem(for: item) else { return }
            _ = SkinService.buy(skin: skin, wallet: wallet)
        case .currency:
            guard let amount = item.amount else { return }

            switch item.currency {
            case .coins:
                wallet.coins += amount
            case .crystals:
                wallet.crystals += amount
            case .shards:
                wallet.shards += amount
            case .realMoney:
                break
            }

            spendCurrency(for: item, wallet: wallet)
        }
    }

    private func ensureSelectedTab() {
        if selectedTab == nil || !tabs.contains(where: { $0.currency == selectedTab?.currency }) {
            selectedTab = tabs.first
        }
    }

    private func canAfford(_ item: ShopItem, wallet: PlayerWallet) -> Bool {
        guard item.productId == nil else { return true }

        switch item.currency {
        case .coins:
            return wallet.coins >= (item.price ?? 0)
        case .crystals:
            return wallet.crystals >= (item.price ?? 0)
        case .shards:
            return wallet.shards >= (item.price ?? 0)
        case .realMoney:
            return true
        }
    }

    private func isOwned(_ item: ShopItem) -> Bool {
        guard let skinId = item.skinId else { return false }
        return gameState.wallet?.ownedSkins.contains(skinId) == true
    }

    private func isEquipped(_ item: ShopItem) -> Bool {
        guard let skinId = item.skinId else { return false }
        return gameState.wallet?.equippedSkin == skinId
    }

    private func priceText(for item: ShopItem) -> String {
        if let product = store.product(for: item.productId) {
            return product.displayPrice
        }

        if let price = item.price {
            return "\(price)"
        }

        return "-"
    }

    private func amountLabel(for item: ShopItem) -> String {
        switch item.currency {
        case .coins:
            return "COINS"
        case .crystals, .realMoney:
            return "CRYSTALS"
        case .shards:
            return "SHARDS"
        }
    }

    private func highlightColor(for item: ShopItem) -> Color {
        item.currency == .shards ? .yellow : .cyan
    }

    private func cardBorderColor(for item: ShopItem) -> Color {
        item.currency == .shards ? Color.yellow.opacity(0.5) : Color.cyan.opacity(0.4)
    }

    private func badgeText(for item: ShopItem) -> String {
        if item.productId != nil {
            return "PACK"
        }

        switch item.type {
        case .currency:
            return "ITEM"
        case .skin:
            return item.currency == .shards ? "EVENT" : "SKIN"
        }
    }

    private func buttonState(for item: ShopItem, wallet: PlayerWallet) -> ShopButtonState {
        let owned = isOwned(item)
        let equipped = isEquipped(item)
        let isStoreItem = item.productId != nil

        if item.type == .skin, equipped {
            return ShopButtonState(
                title: "EQUIPPED",
                backgroundColor: Color.cyan.opacity(0.35),
                isDisabled: true
            )
        }

        if item.type == .skin, owned {
            return ShopButtonState(
                title: "OWNED",
                backgroundColor: Color.white.opacity(0.2),
                isDisabled: true
            )
        }

        let affordable = canAfford(item, wallet: wallet)
        return ShopButtonState(
            title: store.purchaseInProgress && isStoreItem
                ? "PROCESSING"
                : affordable ? "BUY" : "NOT ENOUGH",
            backgroundColor: affordable ? highlightColor(for: item) : Color.gray.opacity(0.25),
            isDisabled: store.purchaseInProgress || (!affordable && item.productId == nil)
        )
    }

    private func spendCurrency(
        for item: ShopItem,
        wallet: PlayerWallet
    ) {
        switch item.currency {
        case .coins:
            wallet.coins -= item.price ?? 0
        case .crystals:
            wallet.crystals -= item.price ?? 0
        case .shards:
            wallet.shards -= item.price ?? 0
        case .realMoney:
            break
        }
    }

    private func applyOwnedSkin(
        for item: ShopItem,
        wallet: PlayerWallet
    ) {
        guard let skinId = item.skinId else { return }

        if !wallet.ownedSkins.contains(skinId) {
            wallet.ownedSkins.append(skinId)
        }
        wallet.equippedSkin = skinId
    }

    private func skinItem(for item: ShopItem) -> SkinItem? {
        guard
            item.type == .skin,
            let skinId = item.skinId,
            let price = item.price
        else {
            return nil
        }

        return SkinItem(
            id: skinId,
            name: item.name,
            previewImage: item.preview,
            fighterSprite: skinId,
            price: price,
            currency: item.currency
        )
    }

    private func currencyIcon(for currency: Currency) -> String {
        switch currency {
        case .coins:
            return "icon_coin"
        case .crystals:
            return "icon_crystal"
        case .shards:
            return "icon_shard"
        case .realMoney:
            return "icon_crystal"
        }
    }

    private func title(for currency: Currency) -> String {
        switch currency {
        case .coins:
            return "Coins"
        case .crystals:
            return "Crystals"
        case .shards:
            return "Shards"
        case .realMoney:
            return "Premium"
        }
    }

    private func icon(for currency: Currency) -> String {
        switch currency {
        case .coins:
            return "icon_coin"
        case .crystals:
            return "icon_crystal"
        case .shards:
            return "icon_shard"
        case .realMoney:
            return "icon_crystal"
        }
    }

    private var emptyState: some View {
        Text("Shop is empty")
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.top, 40)
    }
}

private struct ShopButtonState {
    let title: String
    let backgroundColor: Color
    let isDisabled: Bool
}
