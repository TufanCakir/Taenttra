//
//  DailyView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct DailyView: View {
    private struct DailyReward: Identifiable {
        let day: Int
        let title: String
        let value: String
        let accent: Color
        let apply: (PlayerWallet) -> Void

        var id: Int { day }
    }

    @EnvironmentObject private var gameState: GameState

    @State private var feedbackMessage: String?
    @State private var rewardToastEntries: [RewardToastEntry] = []

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private let rewards: [DailyReward] = [
        DailyReward(day: 1, title: "Coins", value: "+500", accent: .yellow, apply: { $0.coins += 500 }),
        DailyReward(day: 2, title: "Crystals", value: "+120", accent: .cyan, apply: { $0.crystals += 120 }),
        DailyReward(day: 3, title: "Shards", value: "+60", accent: .orange, apply: { $0.shards += 60 }),
        DailyReward(day: 4, title: "Coins", value: "+900", accent: .yellow, apply: { $0.coins += 900 }),
        DailyReward(day: 5, title: "Crystals", value: "+180", accent: .cyan, apply: { $0.crystals += 180 }),
        DailyReward(day: 6, title: "Shards", value: "+120", accent: .orange, apply: { $0.shards += 120 }),
        DailyReward(day: 7, title: "Jackpot", value: "+400 Crystals", accent: .pink, apply: { $0.crystals += 400 }),
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.05, blue: 0.08),
                    Color(red: 0.02, green: 0.03, blue: 0.15),
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
                    rewardGrid
                }
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if !rewardToastEntries.isEmpty {
                RewardToastOverlay(
                    heading: "DAILY CLAIMED",
                    entries: rewardToastEntries
                ) {
                    rewardToastEntries = []
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                tag("DAILY", color: .cyan)
                Spacer()
                tag("STREAK \(wallet?.dailyStreak ?? 0)", color: .white)
            }

            Text("CHECK-IN BOARD")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text(feedbackMessage ?? dailyMessage)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Button {
                claimDailyReward()
            } label: {
                Text(canClaimToday ? "CLAIM DAILY REWARD" : "ALREADY CLAIMED TODAY")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(canClaimToday ? Color.cyan : Color.gray.opacity(0.35)))
            }
            .disabled(!canClaimToday)
            .buttonStyle(.plain)
        }
        .padding(22)
        .background(backgroundCard(accent: .cyan))
    }

    private var rewardGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(rewards) { reward in
                rewardCard(reward)
            }
        }
    }

    private var canClaimToday: Bool {
        guard let lastClaim = wallet?.lastDailyClaimAt else { return true }
        return !Calendar.current.isDateInToday(lastClaim)
    }

    private var currentRewardIndex: Int {
        let streak = wallet?.dailyStreak ?? 0
        return max(0, min(streak, rewards.count - 1))
    }

    private var dailyMessage: String {
        canClaimToday
            ? "Your next reward is ready. Keep the streak alive for the day 7 jackpot."
            : "Come back after the next reset to continue your streak."
    }

    private func rewardCard(_ reward: DailyReward) -> some View {
        let isCurrent = reward.day - 1 == currentRewardIndex
        let isClaimed = reward.day <= (wallet?.dailyStreak ?? 0)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("DAY \(reward.day)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.3)
                    .foregroundStyle(reward.accent)

                Spacer()

                if isClaimed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            Text(reward.title.uppercased())
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(reward.value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(reward.accent)

            Spacer()

            Capsule()
                .fill(isCurrent ? reward.accent : Color.white.opacity(0.12))
                .frame(width: isCurrent ? 28 : 16, height: 5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(reward.accent.opacity(isCurrent ? 0.36 : 0.16), lineWidth: 1)
                )
        )
        .opacity(isClaimed && !isCurrent ? 0.65 : 1)
    }

    private func claimDailyReward() {
        guard let wallet, canClaimToday else { return }

        let calendar = Calendar.current
        let now = Date()

        let lastClaim = wallet.lastDailyClaimAt

        if let lastClaim,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(lastClaim, inSameDayAs: yesterday) {
            wallet.dailyStreak = (wallet.dailyStreak % rewards.count) + 1
        } else if let lastClaim, calendar.isDateInToday(lastClaim) {
            return
        } else {
            wallet.dailyStreak = 1
        }

        let rewardIndex = max(0, min(wallet.dailyStreak - 1, rewards.count - 1))
        rewards[rewardIndex].apply(wallet)
        wallet.lastDailyClaimAt = now
        rewardToastEntries = toastEntries(for: rewards[rewardIndex])
        feedbackMessage = "Day \(wallet.dailyStreak) reward claimed."
    }

    private func toastEntries(for reward: DailyReward) -> [RewardToastEntry] {
        switch reward.title.lowercased() {
        case "coins":
            return [RewardToastEntry(label: "Coins", value: reward.value, color: .yellow, iconName: "icon_coin", accent: reward.accent)]
        case "crystals":
            return [RewardToastEntry(label: "Crystals", value: reward.value, color: .cyan, iconName: "icon_crystal", accent: reward.accent)]
        case "shards":
            return [RewardToastEntry(label: "Shards", value: reward.value, color: .orange, iconName: "icon_shard", accent: reward.accent)]
        default:
            return [RewardToastEntry(label: reward.title, value: reward.value, color: reward.accent, iconName: "icon_crystal", accent: reward.accent)]
        }
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
