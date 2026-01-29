//
//  VictoryView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct VictoryView: View {

    let rewards: VictoryRewards
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 36) {
                VictoryHeader(
                    title: "STAGE CLEARED",
                    subtitle: nil
                )

                VStack(spacing: 16) {
                    rewardRow(
                        icon: "icon_coin",
                        title: "Coins",
                        value: rewards.coins
                    )

                    rewardRow(
                        icon: "icon_crystal",
                        title: "Crystals",
                        value: rewards.crystals
                    )

                    // 🏆 Only show when event shards are present
                    if rewards.tournamentShards > 0 {
                        rewardRow(
                            icon: "icon_tournament",
                            title: "Tournament Shards",
                            value: rewards.tournamentShards
                        )
                    }

                    Button(action: onContinue) {
                        Text("CONTINUE")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(.white)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                    }
                }
                .padding(.vertical, 40)
            }
        }
    }

    // MARK: - Reward Row
    private func rewardRow(
        icon: String,
        title: String,
        value: Int
    ) -> some View {
        HStack(spacing: 16) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Text("+\(value)")
                .font(.headline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
#Preview {
    VictoryView(
        rewards: VictoryRewards(
            coins: 100,
            crystals: 20,
            tournamentShards: 25
        ),
        onContinue: {}
    )
}
