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

            // 🖤 Hintergrund
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 36) {

                // TITLE
                Text("STAGE CLEARED")
                    .font(.system(size: 32, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(.white)

                // REWARDS
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
                }
                .padding(.horizontal, 24)

                // CONTINUE
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.headline.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 40)
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
        rewards: VictoryRewards(coins: 100, crystals: 50),
        onContinue: {}
    )
}
