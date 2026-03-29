//
//  SummonView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct SummonView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let heroHeight: CGFloat = 248
        static let orbSize: CGFloat = 292
        static let cardCornerRadius: CGFloat = 28
    }

    private enum SummonAction {
        case single
        case multi

        var cost: Int {
            switch self {
            case .single:
                return 150
            case .multi:
                return 1500
            }
        }

        var pulls: Int {
            switch self {
            case .single:
                return 1
            case .multi:
                return 10
            }
        }

        var title: String {
            switch self {
            case .single:
                return "SINGLE"
            case .multi:
                return "MULTI x10"
            }
        }

        var subtitle: String {
            "\(cost) CRYSTALS"
        }

        var accent: Color {
            switch self {
            case .single:
                return .cyan
            case .multi:
                return .pink
            }
        }

        var systemName: String {
            switch self {
            case .single:
                return "sparkles"
            case .multi:
                return "aqi.medium"
            }
        }
    }

    private enum SummonDrop: Hashable {
        case featuredSkin
        case battleCard(String)
        case shards(Int)
        case crystals(Int)
        case coins(Int)

        var title: String {
            switch self {
            case .featuredSkin:
                return "FEATURED SKIN"
            case .battleCard:
                return "BATTLE CARD UNLOCK"
            case .shards(let amount):
                return "+\(amount) SHARDS"
            case .crystals(let amount):
                return "+\(amount) CRYSTALS"
            case .coins(let amount):
                return "+\(amount) COINS"
            }
        }

        var badge: String {
            switch self {
            case .featuredSkin:
                return "SSR"
            case .battleCard:
                return "CARD"
            case .shards:
                return "SR"
            case .crystals:
                return "R"
            case .coins:
                return "R"
            }
        }

        var accent: Color {
            switch self {
            case .featuredSkin:
                return .pink
            case .battleCard:
                return .cyan
            case .shards:
                return .orange
            case .crystals:
                return .cyan
            case .coins:
                return .yellow
            }
        }

        var iconName: String {
            switch self {
            case .featuredSkin:
                return "sparkles.rectangle.stack.fill"
            case .battleCard:
                return "square.stack.3d.up.fill"
            case .shards:
                return "icon_shard"
            case .crystals:
                return "icon_crystal"
            case .coins:
                return "icon_coin"
            }
        }
    }

    private struct SummonResult {
        let action: SummonAction
        let drops: [SummonDrop]
        let hadFeaturedHit: Bool
        let unlockedSkinItem: ShopItem?
        let unlockedCardTemplate: BattleCardTemplate?
    }

    @EnvironmentObject private var gameState: GameState

    @State private var pulse = false
    @State private var summonResult: SummonResult?
    @State private var rewardShowcase: RewardShowcasePayload?
    @State private var feedbackMessage: String?
    @State private var isSummoning = false

    private let shopData = ShopLoader.load()
    private let seasonCatalog = SeasonPassLoader.load()
    private let battleCardCatalog = BattleCardLoader.load()

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private var featuredSkinItem: ShopItem? {
        shopData.categories
            .flatMap(\.items)
            .first(where: { $0.type == .skin && $0.productId != nil })
    }

    private var selectedDisplay: CharacterDisplay? {
        gameState.characterDisplays.first { $0.key == gameState.selectedCharacterKey }
    }

    private var currentSeason: SeasonPass? {
        if let wallet, let matching = seasonCatalog.seasons.first(where: { $0.id == wallet.currentSeasonID }) {
            return matching
        }

        return seasonCatalog.currentSeason
    }

    private var previewName: String {
        selectedDisplay?.name.uppercased() ?? gameState.selectedCharacterKey.uppercased()
    }

    private var battleCardTemplateMap: [String: BattleCardTemplate] {
        BattleDeckService.templateMap(from: battleCardCatalog)
    }

    private var rewardShowcaseHeading: String {
        switch rewardShowcase {
        case .theme:
            return "THEME UNLOCK"
        case .skin:
            return "FEATURED UNLOCK"
        case .card:
            return "CARD UNLOCK"
        case nil:
            return "UNLOCK"
        }
    }

    private var pityProgress: Int {
        wallet?.summonPity ?? 0
    }

    private var canSingleSummon: Bool {
        (wallet?.crystals ?? 0) >= SummonAction.single.cost && !isSummoning
    }

    private var canMultiSummon: Bool {
        (wallet?.crystals ?? 0) >= SummonAction.multi.cost && !isSummoning
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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VersusHeaderView()

                    heroCard
                    summonActionPanel
                    utilitySection
                    featuredDropsSection
                    rateSection
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if let summonResult, rewardShowcase == nil {
                resultOverlay(for: summonResult)
                    .zIndex(20)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }

            if let rewardShowcase {
                RewardShowcaseOverlay(
                    heading: rewardShowcaseHeading,
                    payload: rewardShowcase
                ) {
                    self.rewardShowcase = nil
                }
                .zIndex(25)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: summonResult != nil)
        .onAppear {
            gameState.loadCharactersIfNeeded()
            if let wallet {
                MissionResetService.syncResets(for: wallet, catalog: MissionLoader.load())
            }
            pulse = true
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.01, blue: 0.09),
                    Color(red: 0.11, green: 0.01, blue: 0.18),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 42)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color.pink.opacity(0.18))
                .frame(width: 380, height: 380)
                .blur(radius: 50)
                .offset(x: 150, y: 130)

            AngularGradient(
                colors: [
                    .clear,
                    .white.opacity(0.08),
                    .clear,
                    Color.pink.opacity(0.22),
                    .clear,
                ],
                center: .center
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.pink.opacity(0.4),
                            Color.purple.opacity(0.24),
                            Color.black.opacity(0.94),
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
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.pink.opacity(0.42),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 12,
                        endRadius: 140
                    )
                )
                .frame(width: Layout.orbSize, height: Layout.orbSize)
                .offset(x: 118, y: -18)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    heroChip(title: "SUMMON", color: .pink)
                    Spacer()
                    heroChip(title: "PITY \(pityProgress)/20", color: .yellow)
                }

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DIMENSION GATE")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(.white)

                        Text(heroSubtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Spacer(minLength: 12)

                    previewOrb
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: Color.pink.opacity(0.18), radius: 22)
    }

    private var heroSubtitle: String {
        if let feedbackMessage {
            return feedbackMessage
        }

        return "Spend crystals for live pulls. Every 20th pull guarantees the featured skin."
    }

    private var previewOrb: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            Color.pink.opacity(0.92),
                            Color.purple.opacity(0.5),
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 72
                    )
                )
                .frame(width: 132, height: 132)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.36), lineWidth: 3)
                )
                .shadow(color: Color.pink.opacity(0.4), radius: 14, y: 6)

            if let item = featuredSkinItem {
                Image(item.preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 118)
                    .scaleEffect(pulse ? 1.03 : 0.97)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)
            } else if let display = selectedDisplay {
                Image(display.previewImage(using: gameState.wallet))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .scaleEffect(pulse ? 1.03 : 0.97)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)
            } else {
                Image(systemName: "sparkles.tv")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.black.opacity(0.76))
            }
        }
    }

    private var summonActionPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionLabel("LIVE PORTAL")
                Spacer()
                Text(previewName)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.64))
            }

            HStack(spacing: 12) {
                summonButton(for: .single, enabled: canSingleSummon)
                summonButton(for: .multi, enabled: canMultiSummon)
            }

            HStack(spacing: 8) {
                liveRateChip(title: "FEATURED", value: "5%", color: .pink)
                liveRateChip(title: "CARDS", value: "15%", color: .cyan)
                liveRateChip(title: "CRYSTALS", value: "25%", color: .mint)
                liveRateChip(title: "COINS", value: "35%", color: .yellow)
            }

            HStack(spacing: 10) {
                statChip(icon: "icon_crystal", title: "CRYSTALS", value: wallet?.crystals ?? 0, color: .cyan)
                statChip(icon: "icon_shard", title: "SHARDS", value: wallet?.shards ?? 0, color: .orange)
                statChip(icon: "icon_coin", title: "PITY", value: pityProgress, color: .yellow)
            }
        }
        .padding(18)
        .background(sectionBackground)
    }

    private var utilitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionLabel("PORTAL LINKS")
                Spacer()
                Text("UTILITY")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.62))
            }

            HStack(spacing: 12) {
                utilityButton(title: "EXCHANGE", subtitle: "TRADE SHARDS", accent: .orange, systemName: "arrow.left.arrow.right", target: .exchange)
                utilityButton(title: "GIFT", subtitle: "CLAIM PACKS", accent: .pink, systemName: "gift.fill", target: .gift)
                utilityButton(title: "DAILY", subtitle: "CHECK-IN", accent: .cyan, systemName: "calendar", target: .daily)
            }

            utilityButton(
                title: "SEASON PASS",
                subtitle: "TRACK REWARDS",
                accent: .green,
                systemName: "shield.lefthalf.filled.badge.checkmark",
                target: .season
            )

            utilityButton(
                title: "MISSIONS",
                subtitle: "CLAIM TASKS",
                accent: .mint,
                systemName: "checklist.checked",
                target: .missiona
            )

            utilityButton(
                title: "CARDS",
                subtitle: "DECK BUILDER",
                accent: .cyan,
                systemName: "square.stack.3d.up.fill",
                target: .cards
            )
        }
        .padding(18)
        .background(sectionBackground)
    }

    private var featuredDropsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionLabel("FEATURED DROPS")
                Spacer()
                Text("LIMITED")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(.pink)
            }

            HStack(spacing: 14) {
                if let item = featuredSkinItem {
                    featuredRewardCard(
                        title: item.name.uppercased(),
                        badge: "SSR",
                        accent: .pink,
                        preview: item.preview
                    )
                }

                featuredRewardCard(
                    title: "SHARD CACHE",
                    badge: "SR",
                    accent: .orange,
                    preview: "icon_shard"
                )

                featuredRewardCard(
                    title: "CRYSTAL BURST",
                    badge: "R",
                    accent: .cyan,
                    preview: "icon_crystal"
                )
            }
        }
        .padding(18)
        .background(sectionBackground)
    }

    private var rateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("DROP TABLE")

            VStack(spacing: 10) {
                rateRow(rank: "FEATURED", rate: "5% / GUARANTEED AT 20", color: .pink)
                rateRow(rank: "BATTLE CARD", rate: "15%", color: .cyan)
                rateRow(rank: "SHARDS", rate: "20%", color: .orange)
                rateRow(rank: "CRYSTALS", rate: "25%", color: .mint)
                rateRow(rank: "COINS", rate: "35%", color: .yellow)
            }
        }
        .padding(18)
        .background(sectionBackground)
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
    }

    private func heroChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.4)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .tracking(2)
            .foregroundStyle(Color.pink.opacity(0.9))
    }

    private func liveRateChip(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.56))

            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func summonButton(
        for action: SummonAction,
        enabled: Bool
    ) -> some View {
        return Button {
            performSummon(action)
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(enabled ? 0.96 : 0.38),
                                    action.accent.opacity(enabled ? 0.9 : 0.3),
                                    action.accent.opacity(enabled ? 0.56 : 0.14),
                                ],
                                center: .center,
                                startRadius: 3,
                                endRadius: 46
                            )
                        )
                        .frame(width: 92, height: 92)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        )

                    if isSummoning {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: action.systemName)
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.black.opacity(0.8))
                    }
                }

                Text(action.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(action.subtitle)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(action.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.44))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(action.accent.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(enabled ? 1 : 0.45)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    private func utilityButton(
        title: String,
        subtitle: String,
        accent: Color,
        systemName: String,
        target: GameScreen
    ) -> some View {
        Button {
            gameState.screen = target
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.92), accent.opacity(0.46)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 62, height: 62)

                    Image(systemName: systemName)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black.opacity(0.8))
                }

                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.58))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(accent.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func statChip(icon: String, title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.56))

                Text("\(value)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.46))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.28), lineWidth: 1)
                )
        )
    }

    private func featuredRewardCard(
        title: String,
        badge: String,
        accent: Color,
        preview: String
    ) -> some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.34),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.82),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .padding(.top, 24)

                Text(badge)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(accent))
                    .padding(8)
            }
            .frame(height: 124)

            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private func rateRow(rank: String, rate: String, color: Color) -> some View {
        HStack {
            Text(rank)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(color)

            Spacer()

            Text(rate)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.44))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private func resultOverlay(for result: SummonResult) -> some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(result.hadFeaturedHit ? "FEATURED HIT" : "SUMMON RESULTS")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white)

                Text(result.action.title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(result.hadFeaturedHit ? Color.pink : .cyan)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(result.drops.enumerated()), id: \.offset) { _, drop in
                            rewardRow(for: drop)
                        }
                    }
                }
                .frame(maxHeight: 280)

                Button {
                    summonResult = nil
                } label: {
                    Text("CONTINUE")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(result.hadFeaturedHit ? Color.pink : .yellow)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.07, green: 0.05, blue: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .shadow(color: .pink.opacity(0.18), radius: 18)
            .padding(.horizontal, 20)
        }
    }

    private func rewardRow(for drop: SummonDrop) -> some View {
        HStack(spacing: 12) {
            if drop.iconName.hasPrefix("icon_") {
                Image(drop.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: drop.iconName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(drop.accent)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(drop.title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(drop.badge)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(drop.accent)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(drop.accent.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func performSummon(_ action: SummonAction) {
        guard let wallet, wallet.crystals >= action.cost, !isSummoning else { return }

        isSummoning = true
        feedbackMessage = nil
        wallet.crystals -= action.cost
        wallet.summonPullCount += action.pulls
        wallet.dailySummonPullCount += action.pulls
        wallet.weeklySummonPullCount += action.pulls
        wallet.seasonPassXP += action.pulls * (currentSeason?.summonPullXP ?? 10)

        let result = rollResult(for: action, wallet: wallet)
        summonResult = result
        rewardShowcase = result.unlockedSkinItem.map {
            .skin(
                title: $0.name,
                preview: $0.preview,
                rarityText: "SSR FEATURED SKIN",
                accent: .pink
            )
        }
        if rewardShowcase == nil, let unlockedCardTemplate = result.unlockedCardTemplate {
            rewardShowcase = .card(template: unlockedCardTemplate)
        }
        isSummoning = false

        if result.hadFeaturedHit {
            feedbackMessage = "Featured pull landed. \(featuredSkinItem?.name ?? "Skin") added to your roster."
        } else if let unlockedCardTemplate = result.unlockedCardTemplate {
            feedbackMessage = "New battle card unlocked: \(unlockedCardTemplate.title)."
        } else {
            feedbackMessage = "Gate stabilized. \(action.pulls) pull\(action.pulls > 1 ? "s" : "") completed."
        }
    }

    private func rollResult(
        for action: SummonAction,
        wallet: PlayerWallet
    ) -> SummonResult {
        var drops: [SummonDrop] = []
        var hadFeaturedHit = false
        var unlockedSkinItem: ShopItem?
        var unlockedCardTemplate: BattleCardTemplate?

        for _ in 0..<action.pulls {
            if shouldAwardFeaturedSkin(wallet: wallet) {
                hadFeaturedHit = true
                wallet.summonPity = 0
                let reward = applyFeaturedReward(to: wallet)
                if case .featuredSkin = reward {
                    unlockedSkinItem = featuredSkinItem
                }
                drops.append(reward)
                continue
            }

            wallet.summonPity += 1

            let roll = Int.random(in: 0..<100)
            switch roll {
            case 0..<20:
                let reward = Int.random(in: 18...40)
                wallet.shards += reward
                drops.append(.shards(reward))
            case 20..<45:
                let reward = Int.random(in: 25...60)
                wallet.crystals += reward
                drops.append(.crystals(reward))
            case 45..<60:
                let reward = applyBattleCardReward(to: wallet)
                if case .battleCard(let templateID) = reward {
                    unlockedCardTemplate = battleCardTemplateMap[templateID]
                }
                drops.append(reward)
            default:
                let reward = Int.random(in: 180...420)
                wallet.coins += reward
                drops.append(.coins(reward))
            }
        }

        return SummonResult(
            action: action,
            drops: drops,
            hadFeaturedHit: hadFeaturedHit,
            unlockedSkinItem: unlockedSkinItem,
            unlockedCardTemplate: unlockedCardTemplate
        )
    }

    private func shouldAwardFeaturedSkin(wallet: PlayerWallet) -> Bool {
        if wallet.summonPity >= 19 {
            return true
        }

        return Int.random(in: 0..<100) < 5
    }

    private func applyFeaturedReward(to wallet: PlayerWallet) -> SummonDrop {
        guard let featuredSkinItem, let skinId = featuredSkinItem.skinId else {
            wallet.shards += 120
            return .shards(120)
        }

        if wallet.ownedSkins.contains(skinId) {
            wallet.shards += 120
            return .shards(120)
        }

        wallet.ownedSkins.append(skinId)
        wallet.equippedSkin = skinId
        return .featuredSkin
    }

    private func applyBattleCardReward(to wallet: PlayerWallet) -> SummonDrop {
        let pool = (
            battleCardCatalog.characters.flatMap(\.cards) + battleCardCatalog.defaults
        ).filter { $0.isTransformVariant != true }
        guard let rolledCard = pool.randomElement() else {
            wallet.shards += 25
            return .shards(25)
        }

        if wallet.ownedBattleCardIDs.contains(rolledCard.id) {
            wallet.shards += 35
            return .shards(35)
        }

        wallet.ownedBattleCardIDs.append(rolledCard.id)
        return .battleCard(rolledCard.id)
    }
}
