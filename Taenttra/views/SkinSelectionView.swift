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
    @Environment(\.modelContext) private var modelContext
    @Query private var wallets: [PlayerWallet]

    private let data = ShopLoader.load()

    private var wallet: PlayerWallet {
        if let w = wallets.first { return w }
        let w = PlayerWallet()
        modelContext.insert(w)
        return w
    }

    private var skinsCategory: ShopCategory? {
        data.categories.first { $0.id.lowercased() == "skins" }
    }

    private var skins: [ShopItem] {
        skinsCategory?.items ?? []
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {

                header

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(skins) { skin in
                            skinRow(skin)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Text("Select Skin")
                .font(.headline.weight(.semibold))

            Spacer()

        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private func miniCurrency(icon: String, value: Int) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)

            Text("\(value)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
        }
    }

    // MARK: - Skin Row (EQUIP ONLY)

    private func skinRow(_ skin: ShopItem) -> some View {
        let owned = wallet.ownedSkins.contains(skin.id)
        let equipped = wallet.equippedSkin == skin.id

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
                guard owned else { return }
                wallet.equippedSkin = skin.id
                gameState.equippedSkinSprite = skin.id
            } label: {
                Text(equipped ? "EQUIPPED" : "EQUIP")
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
    NavigationStack {
        SkinSelectionView()
            .environmentObject(GameState())
    }
}
