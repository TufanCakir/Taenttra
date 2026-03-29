//
//  SeassonView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct SeassonView: View {
    @EnvironmentObject private var gameState: GameState

    @State private var feedbackMessage: String?
    @State private var rewardShowcase: RewardShowcasePayload?
    @State private var rewardToastEntries: [RewardToastEntry] = []

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private let catalog = SeasonPassLoader.load()

    private var currentSeason: SeasonPass? {
        if let wallet, let matching = catalog.seasons.first(where: { $0.id == wallet.currentSeasonID }) {
            return matching
        }

        return catalog.currentSeason
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
                    passTrack
                }
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if let rewardShowcase {
                RewardShowcaseOverlay(
                    heading: "THEME UNLOCKED",
                    payload: rewardShowcase
                ) {
                    self.rewardShowcase = nil
                }
            }

            if !rewardToastEntries.isEmpty {
                RewardToastOverlay(
                    heading: "REWARDS CLAIMED",
                    entries: rewardToastEntries
                ) {
                    rewardToastEntries = []
                }
            }
        }
    }

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.08, blue: 0.07),
                Color(red: 0.03, green: 0.05, blue: 0.12),
                .black,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                tag("SEASON", color: .green)
                Spacer()
                tag("LEVEL \(currentPassLevel)", color: .white)
            }

            Text("BATTLE PASS")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text(feedbackMessage ?? currentSeason?.subtitle ?? "Earn season XP through fights and summons to claim season rewards.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("PASS XP")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(1.3)
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Text("\(wallet?.seasonPassXP ?? 0) XP")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(currentSeason?.accentColor ?? .green)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [currentSeason?.accentColor ?? .green, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * currentTierProgress)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(22)
        .background(backgroundCard(accent: .green))
    }

    private var passTrack: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PASS REWARDS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(currentSeason?.accentColor ?? .green)

            ForEach(currentSeason?.tiers ?? []) { tier in
                tierCard(tier)
            }
        }
        .padding(18)
        .background(backgroundCard(accent: .white))
    }

    private var currentPassLevel: Int {
        let xp = wallet?.seasonPassXP ?? 0
        let xpPerTier = max(1, currentSeason?.xpPerTier ?? 100)
        let tierCount = max(1, currentSeason?.tiers.count ?? 1)
        return min((xp / xpPerTier) + 1, tierCount)
    }

    private var currentTierProgress: CGFloat {
        let xp = wallet?.seasonPassXP ?? 0
        let xpPerTier = max(1, currentSeason?.xpPerTier ?? 100)
        let remainder = xp % xpPerTier
        return CGFloat(remainder) / CGFloat(xpPerTier)
    }

    private func tierCard(_ tier: SeasonPassTier) -> some View {
        let xpPerTier = max(1, currentSeason?.xpPerTier ?? 100)
        let isUnlocked = (wallet?.seasonPassXP ?? 0) >= tier.level * xpPerTier
        let claimID = tierClaimID(for: tier)
        let isClaimed = wallet?.claimedSeasonPassTierIDs.contains(claimID) == true

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(currentSeason?.accentColor ?? .green)
                    .frame(width: 58, height: 58)

                if rewardIcon(for: tier.reward).hasPrefix("icon_") {
                    Image(rewardIcon(for: tier.reward))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: rewardIcon(for: tier.reward))
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black.opacity(0.8))
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("TIER \(tier.level)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(currentSeason?.accentColor ?? .green)

                Text(tier.title.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white)

                Text(tier.rewardText.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.68))
            }

            Spacer()

            Button {
                claim(tier)
            } label: {
                Text(isClaimed ? "CLAIMED" : (isUnlocked ? "CLAIM" : "LOCKED"))
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(isUnlocked && !isClaimed ? (currentSeason?.accentColor ?? .green) : Color.gray.opacity(0.35)))
            }
            .disabled(!isUnlocked || isClaimed)
            .buttonStyle(.plain)

            if let theme = rewardedTheme(for: tier.reward) {
                rewardThemePreview(theme)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke((currentSeason?.accentColor ?? .green).opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isClaimed ? 0.6 : 1)
    }

    private func claim(_ tier: SeasonPassTier) {
        guard let wallet else { return }
        let xpPerTier = max(1, currentSeason?.xpPerTier ?? 100)
        let claimID = tierClaimID(for: tier)
        guard wallet.seasonPassXP >= tier.level * xpPerTier else { return }
        guard !wallet.claimedSeasonPassTierIDs.contains(claimID) else { return }

        wallet.claimedSeasonPassTierIDs.append(claimID)
        ProgressRewardService.apply(tier.reward, to: wallet)
        rewardShowcase = rewardedTheme(for: tier.reward).map { .theme($0) }
        if rewardShowcase == nil {
            rewardToastEntries = toastEntries(for: [tier.reward])
        }
        feedbackMessage = "Tier \(tier.level) reward claimed."
    }

    private func tierClaimID(for tier: SeasonPassTier) -> String {
        "\(currentSeason?.id ?? "season_1"):\(tier.id)"
    }

    private func rewardIcon(for reward: ProgressReward) -> String {
        switch reward.type {
        case .coins:
            return "icon_coin"
        case .crystals:
            return "icon_crystal"
        case .shards:
            return "icon_shard"
        case .pity:
            return "sparkles"
        case .backgroundTheme:
            return "photo.fill"
        }
    }

    private func rewardedTheme(for reward: ProgressReward) -> BackgroundTheme? {
        guard reward.type == .backgroundTheme, let themeID = reward.themeID else { return nil }
        return BackgroundThemeLoader.load().themes.first(where: { $0.id == themeID })
    }

    private func toastEntries(for rewards: [ProgressReward]) -> [RewardToastEntry] {
        rewards.compactMap { reward in
            switch reward.type {
            case .coins:
                return RewardToastEntry(label: "Coins", value: "+\(reward.amount)", color: .yellow, iconName: "icon_coin", accent: .yellow)
            case .crystals:
                return RewardToastEntry(label: "Crystals", value: "+\(reward.amount)", color: .cyan, iconName: "icon_crystal", accent: .cyan)
            case .shards:
                return RewardToastEntry(label: "Shards", value: "+\(reward.amount)", color: .orange, iconName: "icon_shard", accent: .orange)
            case .pity:
                return RewardToastEntry(label: "Pity", value: "+\(reward.amount)", color: .pink, iconName: "system:sparkles", accent: .pink)
            case .backgroundTheme:
                return nil
            }
        }
    }

    private func rewardThemePreview(_ theme: BackgroundTheme) -> some View {
        HStack(spacing: 12) {
            AppBackgroundView(theme: theme, cornerRadius: 18, shadowOpacity: 0.05)
                .frame(width: 96, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.rarity.chipColor.opacity(0.42), lineWidth: 1.2)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("THEME UNLOCK")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.3)
                    .foregroundStyle(theme.rarity.chipColor)

                Text(theme.name.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.white)

                Text("\(theme.rarity.title) • \(theme.unlockSource.title)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(theme.accentColor)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(theme.rarity == .legendary ? theme.rarity.chipColor.opacity(0.08) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.rarity.chipColor.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func tag(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.3)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func backgroundCard(accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accent.opacity(0.14), lineWidth: 1)
            )
    }
}
