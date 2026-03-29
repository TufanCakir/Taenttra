//
//  MissionaView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct MissionaView: View {
    @EnvironmentObject private var gameState: GameState

    @State private var feedbackMessage: String?
    @State private var selectedCategory: MissionCategory = .daily
    @State private var rewardShowcase: RewardShowcasePayload?
    @State private var rewardToastEntries: [RewardToastEntry] = []

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private let catalog = MissionLoader.load()

    private var missions: [MissionDefinition] {
        catalog.missions
    }

    private var filteredMissions: [MissionDefinition] {
        missions.filter { $0.category == selectedCategory }
    }

    private var currentSeasonID: String {
        wallet?.currentSeasonID ?? catalog.seasonID
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.07, blue: 0.06),
                    Color(red: 0.03, green: 0.04, blue: 0.1),
                    .black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
                    categorySection
                    missionsSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if let rewardShowcase {
                RewardShowcaseOverlay(
                    heading: "BACKGROUND CLAIMED",
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
        .onAppear {
            if let wallet {
                MissionResetService.syncResets(for: wallet, catalog: catalog)
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                tag("MISSIONA", color: .mint)
                Spacer()
                tag("\(claimedCount)/\(missions.count) CLAIMED", color: .white)
            }

            Text("ACTIVE CONTRACTS")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text(feedbackMessage ?? "Complete activity goals across summon, daily and season systems to collect rewards.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(22)
        .background(backgroundCard(accent: .mint))
    }

    private var claimedCount: Int {
        guard let wallet else { return 0 }
        return missions.filter {
            wallet.claimedMissionIDs.contains(
                MissionProgressService.claimKey(for: $0, seasonID: currentSeasonID)
            )
        }.count
    }

    private var missionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(selectedCategory.title.uppercased()) TASKS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(selectedCategory.accentColor)

            ForEach(filteredMissions) { mission in
                missionCard(mission)
            }
        }
        .padding(18)
        .background(backgroundCard(accent: .white))
    }

    private var categorySection: some View {
        HStack(spacing: 10) {
            ForEach(MissionCategory.allCases) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    Text(category.title.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.3)
                        .foregroundStyle(selectedCategory == category ? .black : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? category.accentColor : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .stroke(category.accentColor.opacity(selectedCategory == category ? 0 : 0.22), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundCard(accent: selectedCategory.accentColor))
    }

    private func missionCard(_ mission: MissionDefinition) -> some View {
        let progressValue = wallet.map {
            MissionProgressService.progress(for: mission, wallet: $0)
        } ?? 0
        let clampedProgress = min(progressValue, mission.requirement.target)
        let completionRatio = CGFloat(clampedProgress) / CGFloat(mission.requirement.target)
        let claimKey = MissionProgressService.claimKey(for: mission, seasonID: currentSeasonID)
        let isClaimed = wallet?.claimedMissionIDs.contains(claimKey) == true
        let isComplete = progressValue >= mission.requirement.target

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(mission.accentColor)
                        .frame(width: 56, height: 56)

                    Image(systemName: mission.icon)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black.opacity(0.8))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title.uppercased())
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.white)

                    Text(mission.detail)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))

                    Text(mission.rewardText.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(1.1)
                        .foregroundStyle(mission.accentColor)
                }

                Spacer()

                Button {
                    claim(mission)
                } label: {
                    Text(isClaimed ? "CLAIMED" : (isComplete ? "CLAIM" : "LOCKED"))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.1)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(isComplete && !isClaimed ? mission.accentColor : Color.gray.opacity(0.35)))
                }
                .disabled(!isComplete || isClaimed)
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("PROGRESS")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.52))

                    Spacer()

                    Text("\(clampedProgress)/\(mission.requirement.target)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(mission.accentColor)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [mission.accentColor, mission.accentColor.opacity(0.55)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * completionRatio)
                    }
                }
                .frame(height: 8)
            }

            if let theme = rewardedTheme(for: mission) {
                rewardThemePreview(theme, accent: mission.accentColor)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(mission.accentColor.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isClaimed ? 0.6 : 1)
    }

    private func claim(_ mission: MissionDefinition) {
        guard let wallet else { return }
        let claimKey = MissionProgressService.claimKey(for: mission, seasonID: currentSeasonID)
        guard MissionProgressService.progress(for: mission, wallet: wallet) >= mission.requirement.target else { return }
        guard !wallet.claimedMissionIDs.contains(claimKey) else { return }

        wallet.claimedMissionIDs.append(claimKey)
        mission.rewards.forEach { ProgressRewardService.apply($0, to: wallet) }
        rewardShowcase = rewardedTheme(for: mission).map { .theme($0) }
        if rewardShowcase == nil {
            rewardToastEntries = toastEntries(for: mission.rewards)
        }
        feedbackMessage = "\(mission.title) reward claimed."
    }

    private func rewardedTheme(for mission: MissionDefinition) -> BackgroundTheme? {
        let themeID = mission.rewards.first(where: { $0.type == .backgroundTheme })?.themeID
        guard let themeID else { return nil }
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

    private func rewardThemePreview(_ theme: BackgroundTheme, accent: Color) -> some View {
        HStack(spacing: 12) {
            AppBackgroundView(theme: theme, cornerRadius: 18, shadowOpacity: 0.05)
                .frame(width: 96, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.rarity.chipColor.opacity(0.42), lineWidth: 1.2)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("BACKGROUND REWARD")
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
                    .foregroundStyle(accent)
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
