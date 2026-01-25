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
            // Background Overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 32) {

                // TITLE
                Text("STAGE CLEARED")
                    .font(.largeTitle.weight(.heavy))
                    .tracking(2)
                    .foregroundStyle(.yellow)
                    .multilineTextAlignment(.center)

                // REWARDS
                VStack(spacing: 20) {
                    rewardRow(
                        icon: "🪙",
                        title: "Coins",
                        value: rewards.coins
                    )

                    rewardRow(
                        icon: "💎",
                        title: "Crystals",
                        value: rewards.crystals
                    )
                }
                .padding(.horizontal)

                // CONTINUE BUTTON
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(.yellow)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .transition(.opacity.combined(with: .scale))
    }

    // MARK: - Reward Row

    private func rewardRow(
        icon: String,
        title: String,
        value: Int
    ) -> some View {
        HStack(spacing: 16) {

            Text(icon)
                .font(.title2)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Text("+\(value)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.black.opacity(0.3))
        )
    }
}

#Preview {
    VictoryView(
        rewards: VictoryRewards(coins: 100, crystals: 50),
        onContinue: {}
    )
}
