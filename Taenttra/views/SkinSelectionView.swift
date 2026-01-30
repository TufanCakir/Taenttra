//
//  SkinSelectionView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftData
import SwiftUI

struct SkinSelectionView: View {

    @EnvironmentObject var gameState: GameState
    private let data = ShopLoader.load()

    private var skins: [ShopItem] {
        data.categories
            .filter { $0.id == "skins" || $0.id == "event_skins" }
            .flatMap { $0.items }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.black.ignoresSafeArea()

            // ⬅️ BACK
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            if let wallet = gameState.wallet {
                content(wallet: wallet)
                    .padding(.top, 48)  // 🔥 Platz für Button
            } else {
                ProgressView("Loading Skins…")
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Content

    private func content(wallet: PlayerWallet) -> some View {
        VStack(spacing: 16) {

            header

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(skins) { skin in
                        skinCard(skin, wallet: wallet)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }

    private func skinCard(
        _ skin: ShopItem,
        wallet: PlayerWallet
    ) -> some View {

        let owned = wallet.ownedSkins.contains(skin.skinId)
        let equipped = wallet.equippedSkin == skin.skinId
        let isEventSkin = skin.currency == .tournamentShards
        let isNormalSkin = !isEventSkin

        return VStack(spacing: 12) {

            ZStack(alignment: .topTrailing) {

                // 🖼️ Preview
                Image(skin.preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.tertiarySystemBackground))
                    )
                    .overlay {
                        if !owned {
                            Color.black.opacity(0.45)
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }

                // 🏆 EVENT BADGE
                if isEventSkin {
                    Text("EVENT")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.yellow)
                        )
                        .foregroundColor(.black)
                        .padding(8)
                }
            }

            // 🏷️ Name + Status
            VStack(spacing: 4) {
                Text(skin.name)
                    .font(.headline)

                if equipped {
                    statusTag("EQUIPPED", color: .cyan)
                } else if owned {
                    statusTag("OWNED", color: .secondary)
                } else {
                    Text("Locked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // 🎯 Action Button
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if equipped {
                        wallet.equippedSkin = nil
                    } else if owned {
                        wallet.equippedSkin = skin.skinId
                    }
                }
            } label: {
                Text(equipped ? "USE BASE" : "EQUIP")
                    .font(.caption.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                owned
                                    ? (isEventSkin ? Color.yellow : Color.cyan)
                                    : Color.gray.opacity(0.3)
                            )
                    )
                    .foregroundColor(.white)
            }
            .disabled(!owned)
        }
        .frame(width: 220)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black)
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            (isEventSkin
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(Color.cyan.opacity(0.8))),
                            lineWidth: isEventSkin ? 3 : 2
                        )
                }
                .shadow(
                    color: isEventSkin
                        ? Color.yellow.opacity(0.35)
                        : Color.cyan.opacity(0.35),
                    radius: equipped ? 18 : 10,
                    y: equipped ? 6 : 3
                )
        )

        .scaleEffect(equipped ? 1.05 : 1.0)
        .animation(.easeOut(duration: 0.2), value: equipped)
    }

    private func statusTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
            .foregroundColor(color)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Select Skin")
                .font(.headline.weight(.semibold))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Text("No skins available")
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.top, 40)
    }

    // MARK: - Skin Row

    private func skinRow(
        _ skin: ShopItem,
        wallet: PlayerWallet
    ) -> some View {

        let owned = wallet.ownedSkins.contains(skin.skinId)
        let equipped = wallet.equippedSkin == skin.skinId

        return HStack(spacing: 12) {

            Image(skin.preview)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay {
                    if !owned {
                        Color.black.opacity(0.35)
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 8) {
                    Text(skin.name)
                        .font(.headline)

                    if equipped {
                        tag("Equipped")
                    } else if owned {
                        tag("Owned")
                    }
                }

                Text(owned ? "Tap to equip" : "Buy in shop")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {

                    if equipped {
                        // 🔥 SKIN ABLEGEN → BASE
                        wallet.equippedSkin = nil
                    } else if owned {
                        // 🔥 SKIN ANLEGEN
                        wallet.equippedSkin = skin.skinId
                    }
                }
            } label: {
                Text(equipped ? "UNEQUIP" : "EQUIP")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(.secondarySystemBackground))
                    )
            }
            .disabled(!owned || equipped)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Tag

    private func tag(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(.systemFill))
            )
    }
}

#Preview {
    let gs = GameState()
    gs.wallet = PlayerWallet(
        coins: 2000,
        crystals: 10,
        ownedSkins: ["skin_shadow"],
        equippedSkin: "skin_shadow"
    )

    return NavigationStack {
        SkinSelectionView()
            .environmentObject(gs)
    }
}
