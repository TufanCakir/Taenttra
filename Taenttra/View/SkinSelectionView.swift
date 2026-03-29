//
//  SkinSelectionView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct SkinSelectionView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let cardWidth: CGFloat = 248
        static let heroHeight: CGFloat = 212
    }

    @EnvironmentObject var gameState: GameState

    private let data = ShopLoader.load()

    private var skins: [ShopItem] {
        data.categories
            .flatMap(\.items)
            .filter { $0.type == .skin }
            .sorted { $0.name < $1.name }
    }

    private var equippedSkinID: String? {
        gameState.wallet?.equippedSkin
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

            if let wallet = gameState.wallet {
                ScrollView(showsIndicators: false) {
                    content(wallet: wallet)
                        .padding(.top, 56)
                        .padding(.bottom, 28)
                }
            } else {
                ProgressView("Loading Skins…")
                    .foregroundStyle(.white)
            }
        }
    }

    private func content(wallet: PlayerWallet) -> some View {
        VStack(spacing: 18) {
            VersusHeaderView()

            heroCard(wallet: wallet)

            skinCollection(wallet: wallet)
        }
        .padding(.horizontal, Layout.horizontalPadding)
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.07, green: 0.01, blue: 0.18),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -120, y: -240)

            Circle()
                .fill(Color.orange.opacity(0.14))
                .frame(width: 360, height: 360)
                .blur(radius: 48)
                .offset(x: 150, y: 160)

            AngularGradient(
                colors: [
                    .clear,
                    .white.opacity(0.08),
                    .clear,
                    .cyan.opacity(0.14),
                    .clear,
                ],
                center: .center
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }

    private func heroCard(wallet: PlayerWallet) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.35),
                            Color.white.opacity(0.08),
                            Color.black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )

            Circle()
                .fill(Color.cyan.opacity(0.2))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .offset(x: 128, y: -30)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    statusChip(title: "STYLE", color: .cyan)
                    Spacer()
                    statusChip(title: equippedSkinID == nil ? "BASE ACTIVE" : "SKIN ACTIVE", color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("SKIN HANGAR")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Equip owned skins, swap back to base, and highlight your best battle look.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }

                HStack(spacing: 10) {
                    infoChip(title: "OWNED", value: ownedSkinCount(wallet), color: .cyan)
                    infoChip(title: "LOCKED", value: lockedSkinCount(wallet), color: .orange)
                    infoChip(title: "EVENT", value: eventSkinCount, color: .yellow)
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: .cyan.opacity(0.18), radius: 20)
    }

    private func skinCollection(wallet: PlayerWallet) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AVAILABLE SKINS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.cyan)

                Spacer()

                Circle()
                    .fill(Color.cyan)
                    .frame(width: 8, height: 8)
            }

            if skins.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(skins) { skin in
                            skinCard(skin, wallet: wallet)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(18)
        .background(sectionBackground(accent: .cyan))
    }

    private func skinCard(
        _ skin: ShopItem,
        wallet: PlayerWallet
    ) -> some View {
        let owned = skin.skinId.map { wallet.ownedSkins.contains($0) } ?? false
        let equipped = wallet.equippedSkin == skin.skinId
        let isEventSkin = skin.currency == .shards
        let accent = accentColor(for: skin)

        return VStack(spacing: 14) {
            ZStack(alignment: .topTrailing) {
                Image(skin.preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 184)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.58))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(accent.opacity(0.42), lineWidth: 1)
                            )
                    )
                    .overlay {
                        if !owned {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.black.opacity(0.52))

                            Image(systemName: "lock.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                if isEventSkin {
                    Text("EVENT")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.yellow))
                        .foregroundStyle(.black)
                        .padding(8)
                }
            }

            VStack(spacing: 6) {
                Text(skin.name)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                if equipped {
                    statusTag("EQUIPPED", color: accent)
                } else if owned {
                    statusTag("OWNED", color: .white)
                } else {
                    Text("UNLOCK IN SHOP")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.52))
                }
            }

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
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                owned
                                    ? accent
                                    : Color.gray.opacity(0.24)
                            )
                    )
                    .foregroundStyle(owned ? Color.black : Color.white.opacity(0.6))
            }
            .disabled(!owned)
        }
        .padding(18)
        .frame(width: Layout.cardWidth)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(accent.opacity(equipped ? 0.85 : 0.34), lineWidth: equipped ? 2 : 1)
                )
        )
        .shadow(color: accent.opacity(equipped ? 0.26 : 0.14), radius: equipped ? 18 : 12, y: 8)
        .scaleEffect(equipped ? 1.03 : 1)
        .animation(.easeOut(duration: 0.2), value: equipped)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("NO SKINS READY")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white)

            Text("Battle outfits will appear here once the shop loads skin entries.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 42)
    }

    private func accentColor(for skin: ShopItem) -> Color {
        skin.currency == .shards ? .yellow : .cyan
    }

    private func ownedSkinCount(_ wallet: PlayerWallet) -> String {
        "\(wallet.ownedSkins.count)"
    }

    private func lockedSkinCount(_ wallet: PlayerWallet) -> String {
        "\(max(skins.count - wallet.ownedSkins.count, 0))"
    }

    private var eventSkinCount: String {
        "\(skins.filter { $0.currency == .shards }.count)"
    }

    private func infoChip(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(color.opacity(0.9))

            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.38))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func statusChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func statusTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.2)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.16))
            )
            .foregroundStyle(color)
    }

    private func sectionBackground(accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(accent.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: accent.opacity(0.12), radius: 12)
    }
}
