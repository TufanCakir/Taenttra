//
//  ExchangeView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct ExchangeView: View {
    private struct ExchangeOffer: Identifiable {
        let id: String
        let title: String
        let cost: Int
        let reward: Int
        let rewardTitle: String
        let accent: Color
        let icon: String
        let apply: (PlayerWallet) -> Void
    }

    @EnvironmentObject private var gameState: GameState

    @State private var feedbackMessage: String?
    @State private var rewardToastEntries: [RewardToastEntry] = []

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private var offers: [ExchangeOffer] {
        [
            ExchangeOffer(
                id: "crystal_trade",
                title: "Crystal Trade",
                cost: 50,
                reward: 120,
                rewardTitle: "CRYSTALS",
                accent: .cyan,
                icon: "icon_crystal",
                apply: { $0.crystals += 120 }
            ),
            ExchangeOffer(
                id: "coin_trade",
                title: "Coin Trade",
                cost: 30,
                reward: 1000,
                rewardTitle: "COINS",
                accent: .yellow,
                icon: "icon_coin",
                apply: { $0.coins += 1000 }
            ),
            ExchangeOffer(
                id: "pity_boost",
                title: "Pity Boost",
                cost: 80,
                reward: 5,
                rewardTitle: "PITY",
                accent: .pink,
                icon: "sparkles",
                apply: { $0.summonPity = min($0.summonPity + 5, 19) }
            ),
        ]
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
                    offersSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if !rewardToastEntries.isEmpty {
                RewardToastOverlay(
                    heading: "TRADE COMPLETE",
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
                Color(red: 0.05, green: 0.02, blue: 0.08),
                Color(red: 0.08, green: 0.03, blue: 0.02),
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
                chip("EXCHANGE", color: .orange)
                Spacer()
                chip("SHARD MARKET", color: .white)
            }

            Text("TRADE PORTAL")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text(feedbackMessage ?? "Convert shards into crystals, coins or direct pity support.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            HStack(spacing: 10) {
                walletChip("icon_shard", title: "SHARDS", value: wallet?.shards ?? 0, color: .orange)
                walletChip("icon_crystal", title: "CRYSTALS", value: wallet?.crystals ?? 0, color: .cyan)
                walletChip("icon_coin", title: "COINS", value: wallet?.coins ?? 0, color: .yellow)
            }
        }
        .padding(22)
        .background(cardBackground(accent: .orange))
    }

    private var offersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("AVAILABLE DEALS")

            ForEach(offers) { offer in
                exchangeCard(offer)
            }
        }
        .padding(18)
        .background(cardBackground(accent: .white))
    }

    private func exchangeCard(_ offer: ExchangeOffer) -> some View {
        let canAfford = (wallet?.shards ?? 0) >= offer.cost

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(offer.accent.opacity(0.9))
                    .frame(width: 56, height: 56)

                if offer.icon.hasPrefix("icon_") {
                    Image(offer.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: offer.icon)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(offer.title.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white)

                Text("\(offer.cost) SHARDS -> \(offer.reward) \(offer.rewardTitle)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(offer.accent)
            }

            Spacer()

            Button {
                claim(offer)
            } label: {
                Text("TRADE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(canAfford ? offer.accent : Color.gray.opacity(0.4)))
            }
            .disabled(!canAfford)
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(offer.accent.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func claim(_ offer: ExchangeOffer) {
        guard let wallet, wallet.shards >= offer.cost else { return }
        wallet.shards -= offer.cost
        offer.apply(wallet)
        rewardToastEntries = toastEntries(for: offer)
        feedbackMessage = "\(offer.title) completed."
    }

    private func toastEntries(for offer: ExchangeOffer) -> [RewardToastEntry] {
        let iconName = offer.icon.hasPrefix("icon_") ? offer.icon : "system:\(offer.icon)"
        return [
            RewardToastEntry(
                label: offer.rewardTitle,
                value: "+\(offer.reward)",
                color: offer.accent,
                iconName: iconName,
                accent: offer.accent
            ),
        ]
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .tracking(2)
            .foregroundStyle(.orange)
    }

    private func chip(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.3)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func walletChip(_ icon: String, title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.56))

                Text("\(value)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func cardBackground(accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accent.opacity(0.14), lineWidth: 1)
            )
    }
}
