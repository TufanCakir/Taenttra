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

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ✨ CENTER GLOW
            RadialGradient(
                colors: [
                    Color.cyan.opacity(glowPulse ? 0.35 : 0.15),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 260
            )
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: glowPulse
            )

            VStack(spacing: 24) {

                Spacer()

                // 🏆 TITLE
                VStack(spacing: 6) {
                    Text("Stage Cleared")
                        .font(.system(size: 32, weight: .heavy))
                        .tracking(3)
                        .foregroundStyle(.white)
                        .shadow(color: .cyan.opacity(0.6), radius: 12)

                    Text("You Win")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundColor(.cyan.opacity(0.9))
                }
                .scaleEffect(showRewards ? 1 : 0.8)
                .opacity(showRewards ? 1 : 0)

                // 💰 REWARD CARD
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
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.75))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .cyan.opacity(0.3), radius: 20)
                )
                .padding(.horizontal, 24)
                .scaleEffect(showRewards ? 1 : 0.9)
                .opacity(showRewards ? 1 : 0)

                Spacer()

                // ▶️ CONTINUE BUTTON
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .heavy))
                        .tracking(1)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: .cyan.opacity(0.8), radius: 18)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .scaleEffect(showRewards ? 1 : 0.8)
                .opacity(showRewards ? 1 : 0)
            }
        }
        .onAppear {
            glowPulse = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showRewards = true
            }
        }
    }

    // MARK: - Reward Row
    private func rewardRow(
        icon: String,
        title: String,
        value: Int,
        delay: Double,
        highlight: Bool = false
    ) -> some View {

        HStack(spacing: 14) {

            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .shadow(color: highlight ? .yellow.opacity(0.6) : .clear, radius: 10)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Text("+\(value)")
                .font(.system(size: 20, weight: .heavy))
                .monospacedDigit()
                .foregroundColor(highlight ? .yellow : .white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            highlight
                                ? Color.yellow.opacity(0.6)
                                : Color.white.opacity(0.1),
                            lineWidth: highlight ? 1.5 : 1
                        )
                )
        )
        .offset(y: showRewards ? 0 : 25)
        .opacity(showRewards ? 1 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7)
                .delay(delay),
            value: showRewards
        )
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
