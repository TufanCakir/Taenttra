//
//  SkinSelectionView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftData
import SwiftUI

struct SkinSelectionView: View {

    @EnvironmentObject var gameState: GameState
    private let data = ShopLoader.load()

    private var skins: [ShopItem] {
        data.categories
            .flatMap { $0.items }
            .sorted { $0.name < $1.name }
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

        guard let skinId = skin.skinId else {
            return AnyView(EmptyView()) // oder skip
        }

        let owned = wallet.ownedSkins.contains(skinId)
        let equipped = wallet.equippedSkin == skinId

        return AnyView(
            VStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if equipped {
                            wallet.equippedSkin = nil
                        } else if owned {
                            wallet.equippedSkin = skinId   // ✅ FIX
                        }
                    }
                } label: {
                    Text(equipped ? "Use Base" : "Equip")
                }
                .disabled(!owned)
            }
        )
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

        guard let skinId = skin.skinId else {
            return AnyView(EmptyView())
        }

        let owned = wallet.ownedSkins.contains(skinId)
        let equipped = wallet.equippedSkin == skinId

        return AnyView(
            HStack {
                Button {
                    withAnimation {
                        if equipped {
                            wallet.equippedSkin = nil
                        } else if owned {
                            wallet.equippedSkin = skinId   // ✅ FIX
                        }
                    }
                } label: {
                    Text(equipped ? "Unequip" : "Equip")
                }
            }
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
