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

    @State private var showRewards = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {

            // 🌑 BACKGROUND
            LinearGradient(
                colors: [.black, .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ✨ GLOW
            RadialGradient(
                colors: [
                    Color.cyan.opacity(glowPulse ? 0.45 : 0.2),
                    .clear,
                ],
                center: .center,
                startRadius: 30,
                endRadius: 220
            )
            .blendMode(.screen)
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                value: glowPulse
            )

            VStack(spacing: 28) {

                // 🏆 HEADER
                VStack(spacing: 4) {
                    Text("STAGE CLEARED")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(3)
                        .shadow(color: .cyan.opacity(0.6), radius: 12)

                    Text("YOU WIN")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.cyan.opacity(0.9))
                        .tracking(2)
                }
                .scaleEffect(showRewards ? 1 : 0.8)
                .opacity(showRewards ? 1 : 0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.6),
                    value: showRewards
                )

                // 💰 REWARDS
                VStack(spacing: 14) {

                    rewardRow(
                        icon: "icon_coin",
                        title: "COINS",
                        value: rewards.coins,
                        delay: 0.1
                    )

                    rewardRow(
                        icon: "icon_crystal",
                        title: "CRYSTALS",
                        value: rewards.crystals,
                        delay: 0.25
                    )

                    if rewards.tournamentShards > 0 {
                        rewardRow(
                            icon: "icon_tournament",
                            title: "TOURNAMENT SHARDS",
                            value: rewards.tournamentShards,
                            delay: 0.4,
                            highlight: true
                        )
                    }
                }
                .padding(.top, 12)

                Spacer()

                // ▶️ CONTINUE
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .heavy))
                        .tracking(1)
                        .foregroundColor(.black)
                        .padding(.horizontal, 52)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .cornerRadius(14)
                        .shadow(color: .cyan.opacity(0.8), radius: 16)
                }
                .scaleEffect(showRewards ? 1 : 0.7)
                .opacity(showRewards ? 1 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.6),
                    value: showRewards
                )
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            glowPulse = true
            withAnimation {
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

        HStack(spacing: 16) {

            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .shadow(
                    color: highlight ? .yellow.opacity(0.6) : .black,
                    radius: 6
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Text("+\(value)")
                .font(.system(size: 18, weight: .heavy))
                .monospacedDigit()
                .foregroundStyle(highlight ? .yellow : .white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            highlight
                                ? Color.yellow.opacity(0.7)
                                : Color.cyan.opacity(0.25),
                            lineWidth: highlight ? 2 : 1
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            highlight
                                ? Color.yellow.opacity(0.6)
                                : Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                )
        )
        .offset(y: showRewards ? 0 : 30)
        .opacity(showRewards ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
                .delay(delay),
            value: showRewards
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
