//
//  Taenttra.swift
//  Slayken
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct VictoryView: View {
    let rewards: VictoryRewards
    let onContinue: () -> Void

    @State private var showRewards = false
    @State private var glowPulse = false
    @State private var showRewardToast = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 24) {
                Spacer()

                VictoryHeader(
                    title: "STAGE CLEARED",
                    subtitle: "You Win"
                )
                .scaleEffect(showRewards ? 1 : 0.8)
                .opacity(showRewards ? 1 : 0)

                VStack(spacing: 14) {
                    rewardRow(icon: "icon_coin", title: "Coins", value: rewards.coins, delay: 0.1)
                    rewardRow(icon: "icon_crystal", title: "Crystals", value: rewards.crystals, delay: 0.2)

                    if rewards.shards > 0 {
                        rewardRow(
                            icon: "icon_shard",
                            title: "Shards",
                            value: rewards.shards,
                            delay: 0.3,
                            highlight: true
                        )
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.cyan.opacity(0.24), lineWidth: 1)
                        )
                        .shadow(color: .cyan.opacity(0.22), radius: 20)
                )
                .padding(.horizontal, 24)
                .scaleEffect(showRewards ? 1 : 0.9)
                .opacity(showRewards ? 1 : 0)

                Spacer()

                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.white, .cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .cyan.opacity(0.8), radius: 18)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .scaleEffect(showRewards ? 1 : 0.8)
                .opacity(showRewards ? 1 : 0)
            }

            if showRewardToast, !rewardToastEntries.isEmpty {
                RewardToastOverlay(
                    heading: "BATTLE REWARDS",
                    entries: rewardToastEntries
                ) {
                    showRewardToast = false
                }
            }
        }
        .onAppear {
            glowPulse = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showRewards = true
            }
            showRewardToast = !rewardToastEntries.isEmpty
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.01, blue: 0.16),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(glowPulse ? 0.24 : 0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 36)
                .animation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: glowPulse
                )

            Circle()
                .fill(Color.yellow.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 42)
                .offset(x: 0, y: 160)
        }
    }

    private func rewardRow(
        icon: String,
        title: String,
        value: Int,
        delay: Double,
        highlight: Bool = false
    ) -> some View {
        RewardView(
            label: title,
            value: "+\(value)",
            color: highlight ? .yellow : .white,
            iconName: icon,
            accent: highlight ? .yellow : .cyan
        )
        .offset(y: showRewards ? 0 : 25)
        .opacity(showRewards ? 1 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7)
                .delay(delay),
            value: showRewards
        )
    }

    private var rewardToastEntries: [RewardToastEntry] {
        var entries: [RewardToastEntry] = []

        if rewards.coins > 0 {
            entries.append(
                RewardToastEntry(
                    label: "Coins",
                    value: "+\(rewards.coins)",
                    color: .yellow,
                    iconName: "icon_coin",
                    accent: .yellow
                )
            )
        }

        if rewards.crystals > 0 {
            entries.append(
                RewardToastEntry(
                    label: "Crystals",
                    value: "+\(rewards.crystals)",
                    color: .cyan,
                    iconName: "icon_crystal",
                    accent: .cyan
                )
            )
        }

        if rewards.shards > 0 {
            entries.append(
                RewardToastEntry(
                    label: "Shards",
                    value: "+\(rewards.shards)",
                    color: .orange,
                    iconName: "icon_shard",
                    accent: .orange
                )
            )
        }

        return entries
    }
}

/*#Preview {
    VictoryView(
        rewards: VictoryRewards(
            coins: 100,
            crystals: 20,
            shards: 25
        ),
        onContinue: {}
    )
}*/
