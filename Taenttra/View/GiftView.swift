//
//  GiftView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct GiftView: View {
    private struct GiftPack: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let accent: Color
        let rewardText: String
        let apply: (PlayerWallet) -> Void
    }

    @EnvironmentObject private var gameState: GameState

    @State private var feedbackMessage: String?
    @State private var rewardToastEntries: [RewardToastEntry] = []

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private let packs: [GiftPack] = [
        GiftPack(
            id: "launch_pack",
            title: "Launch Pack",
            subtitle: "Starter support cache",
            accent: .pink,
            rewardText: "+300 Crystals / +1000 Coins",
            apply: {
                $0.crystals += 300
                $0.coins += 1000
            }
        ),
        GiftPack(
            id: "arena_boost",
            title: "Arena Boost",
            subtitle: "Battle prep reward",
            accent: .cyan,
            rewardText: "+120 Shards / +500 Coins",
            apply: {
                $0.shards += 120
                $0.coins += 500
            }
        ),
        GiftPack(
            id: "summon_token",
            title: "Summon Cache",
            subtitle: "Portal access grant",
            accent: .orange,
            rewardText: "+450 Crystals",
            apply: {
                $0.crystals += 450
            }
        ),
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.02, blue: 0.08),
                    Color(red: 0.03, green: 0.01, blue: 0.13),
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
                    giftsSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if !rewardToastEntries.isEmpty {
                RewardToastOverlay(
                    heading: "GIFT CLAIMED",
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
                tag("GIFT", color: .pink)
                Spacer()
                tag("INBOX", color: .white)
            }

            Text("REWARD MAILBOX")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text(feedbackMessage ?? "Claim one-time reward packs and mailbox support drops.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(22)
        .background(backgroundCard(accent: .pink))
    }

    private var giftsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CLAIMABLE PACKS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(.pink)

            ForEach(packs) { pack in
                giftCard(pack)
            }
        }
        .padding(18)
        .background(backgroundCard(accent: .white))
    }

    private func giftCard(_ pack: GiftPack) -> some View {
        let alreadyClaimed = wallet?.claimedGiftPackIDs.contains(pack.id) == true

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(pack.accent)
                    .frame(width: 58, height: 58)

                Image(systemName: "gift.fill")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black.opacity(0.82))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pack.title.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white)

                Text(pack.subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))

                Text(pack.rewardText.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(pack.accent)
            }

            Spacer()

            Button {
                claim(pack)
            } label: {
                Text(alreadyClaimed ? "CLAIMED" : "CLAIM")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(alreadyClaimed ? Color.gray.opacity(0.35) : pack.accent))
            }
            .disabled(alreadyClaimed)
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(pack.accent.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(alreadyClaimed ? 0.58 : 1)
    }

    private func claim(_ pack: GiftPack) {
        guard let wallet, !wallet.claimedGiftPackIDs.contains(pack.id) else { return }
        wallet.claimedGiftPackIDs.append(pack.id)
        pack.apply(wallet)
        rewardToastEntries = toastEntries(for: pack)
        feedbackMessage = "\(pack.title) claimed."
    }

    private func toastEntries(for pack: GiftPack) -> [RewardToastEntry] {
        switch pack.id {
        case "launch_pack":
            return [
                RewardToastEntry(label: "Crystals", value: "+300", color: .cyan, iconName: "icon_crystal", accent: .cyan),
                RewardToastEntry(label: "Coins", value: "+1000", color: .yellow, iconName: "icon_coin", accent: .yellow),
            ]
        case "arena_boost":
            return [
                RewardToastEntry(label: "Shards", value: "+120", color: .orange, iconName: "icon_shard", accent: .orange),
                RewardToastEntry(label: "Coins", value: "+500", color: .yellow, iconName: "icon_coin", accent: .yellow),
            ]
        case "summon_token":
            return [
                RewardToastEntry(label: "Crystals", value: "+450", color: .cyan, iconName: "icon_crystal", accent: .cyan),
            ]
        default:
            return []
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
