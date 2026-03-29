//
//  ShopView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import StoreKit
import SwiftUI

struct ShopView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let cardWidth: CGFloat = 248
        static let heroHeight: CGFloat = 212
        static let cardCornerRadius: CGFloat = 28
    }

    @EnvironmentObject var gameState: GameState

    private let data = ShopLoader.load()
    private let backgroundCatalog = BackgroundThemeLoader.load()

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
            backgroundLayer

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            if let wallet = gameState.wallet {
                ScrollView(showsIndicators: false) {
                    content(wallet: wallet)
                        .padding(.top, 56)
                        .padding(.bottom, 28)
                }
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
        VStack(spacing: 18) {
            VersusHeaderView()

            heroCard(wallet: wallet)
            backgroundHubCard

            tabSection

            shopCards(wallet: wallet)

            errorBanner
        }
        .padding(.horizontal, Layout.horizontalPadding)
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
                    .padding(.horizontal, 2)
                    .padding(.vertical, 12)
                }
                .id(selectedTab?.currency)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            AppBackgroundView(
                theme: BackgroundThemeService.theme(for: gameState.wallet?.selectedBackgroundThemeID)
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -120, y: -240)

            Circle()
                .fill(activeAccentColor.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 48)
                .offset(x: 150, y: 160)

            AngularGradient(
                colors: [
                    .clear,
                    .white.opacity(0.08),
                    .clear,
                    activeAccentColor.opacity(0.18),
                    .clear,
                ],
                center: .center
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }

    private var backgroundHubCard: some View {
        Button {
            gameState.screen = .backgrounds
        } label: {
            HStack(spacing: 16) {
                AppBackgroundView(
                    theme: BackgroundThemeService.theme(for: gameState.wallet?.selectedBackgroundThemeID),
                    cornerRadius: 20,
                    shadowOpacity: 0.08
                )
                .frame(width: 112, height: 88)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("BACKGROUND LAB")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(.white)

                    Text("Buy PNG arenas and custom FX themes, then equip one globally for the whole app.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)

                    Text(BackgroundThemeService.theme(for: gameState.wallet?.selectedBackgroundThemeID).name.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(1.1)
                        .foregroundStyle(activeAccentColor)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(activeAccentColor)
            }
            .padding(18)
            .background(sectionBackground(accent: activeAccentColor))
        }
        .buttonStyle(.plain)
    }

    private func heroCard(wallet: PlayerWallet) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            activeAccentColor.opacity(0.42),
                            Color.white.opacity(0.08),
                            Color.black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )

            Circle()
                .fill(activeAccentColor.opacity(0.22))
                .frame(width: 180, height: 180)
                .blur(radius: 16)
                .offset(x: 132, y: -32)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    statusChip(title: "SHOP", color: activeAccentColor)
                    Spacer()
                    statusChip(title: selectedTabTitle.uppercased(), color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("BATTLE MARKET")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text(heroSubtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }

                HStack(spacing: 10) {
                    walletChip(icon: "icon_coin", label: "COINS", value: wallet.coins, color: .yellow)
                    walletChip(icon: "icon_crystal", label: "CRYSTALS", value: wallet.crystals, color: .cyan)
                    walletChip(icon: "icon_shard", label: "SHARDS", value: wallet.shards, color: .orange)
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: activeAccentColor.opacity(0.18), radius: 20)
    }

    private var tabSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("STORE CHANNELS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(activeAccentColor)

                Spacer()

                Circle()
                    .fill(activeAccentColor)
                    .frame(width: 8, height: 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(tabs) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(tab.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)

                                Text(tab.title.uppercased())
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .tracking(1.3)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        selectedTab?.currency == tab.currency
                                            ? activeAccentColor.opacity(0.92)
                                            : Color.white.opacity(0.05)
                                    )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedTab?.currency == tab.currency
                                            ? Color.white.opacity(0.0)
                                            : Color.white.opacity(0.18),
                                        lineWidth: 1
                                    )
                            )
                            .foregroundStyle(selectedTab?.currency == tab.currency ? .black : .white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(18)
        .background(sectionBackground(accent: activeAccentColor))
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
                    itemPreview(for: item)
                        .frame(height: 112)

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
                .frame(height: 164)
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.58))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(cardBorderColor(for: item), lineWidth: 1)
                        )
                )

                HStack(spacing: 6) {
                    if let theme = backgroundTheme(for: item) {
                        Text(theme.rarity.title)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(theme.rarity.chipColor))
                            .foregroundStyle(.black)

                        Text(theme.kind == .asset ? "PNG" : "FX")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(theme.accentColor))
                            .foregroundStyle(.black)
                    }

                    Text(badgeText(for: item))
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(highlightColor(for: item)))
                        .foregroundStyle(.black)
                }
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
                } else if item.type == .background, let theme = backgroundTheme(for: item) {
                    Text("\(theme.rarity.title) • \(theme.kind == .asset ? "PNG" : "FX")")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(theme.rarity.chipColor)
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
                    .fill(Color.black.opacity(0.55))
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
        .padding(18)
        .frame(width: Layout.cardWidth)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                        .stroke(cardBorderColor(for: item), lineWidth: isEventItem ? 1.5 : 1)
                )
        )
        .shadow(color: highlightColor(for: item).opacity(0.16), radius: 14, y: 8)
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
            case .background:
                applyOwnedBackground(for: item, wallet: wallet)
            }
        }
    }

    private func buyWithGameCurrency(_ item: ShopItem, wallet: PlayerWallet) {
        guard canAfford(item, wallet: wallet) else { return }

        switch item.type {
        case .skin:
            if isOwned(item) {
                guard let skin = skinItem(for: item) else { return }
                SkinService.equip(skin: skin, wallet: wallet)
            } else {
                guard let skin = skinItem(for: item) else { return }
                _ = SkinService.buy(skin: skin, wallet: wallet)
            }
        case .background:
            guard let backgroundId = item.backgroundId else { return }
            if BackgroundThemeService.isOwned(themeID: backgroundId, wallet: wallet) {
                BackgroundThemeService.equip(themeID: backgroundId, wallet: wallet)
            } else {
                _ = BackgroundThemeService.buy(
                    themeID: backgroundId,
                    price: item.price ?? 0,
                    currency: item.currency,
                    wallet: wallet
                )
            }
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
        guard let wallet = gameState.wallet else { return false }

        switch item.type {
        case .skin:
            guard let skinId = item.skinId else { return false }
            return wallet.ownedSkins.contains(skinId)
        case .background:
            guard let backgroundId = item.backgroundId else { return false }
            return BackgroundThemeService.isOwned(themeID: backgroundId, wallet: wallet)
        case .currency:
            return false
        }
    }

    private func isEquipped(_ item: ShopItem) -> Bool {
        guard let wallet = gameState.wallet else { return false }

        switch item.type {
        case .skin:
            guard let skinId = item.skinId else { return false }
            return wallet.equippedSkin == skinId
        case .background:
            guard let backgroundId = item.backgroundId else { return false }
            return BackgroundThemeService.isEquipped(themeID: backgroundId, wallet: wallet)
        case .currency:
            return false
        }
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
        if let theme = backgroundTheme(for: item) {
            return theme.rarity.chipColor
        }

        return item.currency == .shards ? Color.yellow : Color.cyan
    }

    private func cardBorderColor(for item: ShopItem) -> Color {
        if let theme = backgroundTheme(for: item) {
            return theme.rarity.chipColor.opacity(0.45)
        }
        return item.currency == .shards ? Color.yellow.opacity(0.5) : Color.cyan.opacity(0.4)
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
        case .background:
            return "BG"
        }
    }

    private func buttonState(for item: ShopItem, wallet: PlayerWallet) -> ShopButtonState {
        let owned = isOwned(item)
        let equipped = isEquipped(item)
        let isStoreItem = item.productId != nil

        if item.type != .currency, equipped {
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

        if item.type == .background, owned {
            return ShopButtonState(
                title: "SELECT",
                backgroundColor: activeAccentColor,
                isDisabled: false
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

    private func applyOwnedBackground(
        for item: ShopItem,
        wallet: PlayerWallet
    ) {
        guard let backgroundId = item.backgroundId else { return }
        BackgroundThemeService.unlock(themeID: backgroundId, wallet: wallet)
    }

    @ViewBuilder
    private func itemPreview(for item: ShopItem) -> some View {
        if item.type == .background, let theme = backgroundTheme(for: item) {
            AppBackgroundView(theme: theme, cornerRadius: 20, shadowOpacity: 0.05)
        } else {
            Image(item.preview)
                .resizable()
                .scaledToFit()
        }
    }

    private func backgroundTheme(for item: ShopItem) -> BackgroundTheme? {
        guard let backgroundId = item.backgroundId else { return nil }
        return backgroundCatalog.themes.first(where: { $0.id == backgroundId })
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
        VStack(spacing: 10) {
            Text("NO ITEMS READY")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white)

            Text("This channel has no active battle goods right now.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 42)
        .background(sectionBackground(accent: activeAccentColor))
    }

    private var errorBanner: some View {
        Group {
            if let errorMessage = store.lastErrorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(sectionBackground(accent: .red))
            }
        }
    }

    private var activeAccentColor: Color {
        guard let currency = selectedTab?.currency else {
            return .cyan
        }

        switch currency {
        case .coins:
            return .yellow
        case .crystals, .realMoney:
            return .cyan
        case .shards:
            return .orange
        }
    }

    private var selectedTabTitle: String {
        selectedTab?.title ?? "Shop"
    }

    private var heroSubtitle: String {
        switch selectedTab?.currency {
        case .coins:
            return "Build your stockpile with fast coin boosts and utility packs."
        case .crystals:
            return "Premium currency packs for skins, rewards, and fast unlocks."
        case .shards:
            return "Limited event rewards and special skins powered by shard drops."
        case .realMoney:
            return "Direct premium offers linked to the App Store purchase flow."
        case .none:
            return "Choose a channel and load up your battle inventory."
        }
    }

    private func walletChip(
        icon: String,
        label: String,
        value: Int,
        color: Color
    ) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(color.opacity(0.9))

                Text("\(value)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.38))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func statusChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func sectionBackground(accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(accent.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: accent.opacity(0.12), radius: 12)
    }
}

private struct ShopButtonState {
    let title: String
    let backgroundColor: Color
    let isDisabled: Bool
}
