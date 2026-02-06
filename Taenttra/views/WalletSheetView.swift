//
//  WalletSheetView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 06.02.26.
//

import SwiftUI

struct WalletSheetView: View {

    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {

            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                // 🟢 Handle
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                // 🏦 Title
                Text("WALLET")
                    .font(.system(size: 18, weight: .heavy))
                    .tracking(3)
                    .foregroundColor(.white)

                VStack(spacing: 16) {

                    walletRow(
                        icon: "icon_coin",
                        title: "COINS",
                        value: gameState.wallet.coins,
                        color: .yellow,
                        description: "Earned in fights. Used in the shop."
                    )

                    walletRow(
                        icon: "icon_crystal",
                        title: "CRYSTALS",
                        value: gameState.wallet.crystals,
                        color: .cyan,
                        description: "Rare currency. Used for premium items."
                    )

                    walletRow(
                        icon: "icon_tournament",
                        title: "TOURNAMENT SHARDS",
                        value: gameState.wallet.tournamentShards,
                        color: .orange,
                        description: "Event-only rewards. Unlock exclusive content."
                    )
                }
                .padding(.horizontal, 20)

                Spacer()

                // ❌ Close
                Button {
                    dismiss()
                } label: {
                    Text("CLOSE")
                        .font(.system(size: 14, weight: .heavy))
                        .tracking(2)
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Row

    private func walletRow(
        icon: String,
        title: String,
        value: Int,
        color: Color,
        description: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 12) {

                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(value)")
                    .font(.system(size: 18, weight: .heavy))
                    .monospacedDigit()
                    .foregroundColor(color)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.65))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.35), lineWidth: 1)
                )
        )
    }
}
