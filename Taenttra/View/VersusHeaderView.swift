//
//  VersusHeaderView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct VersusHeaderView: View {
    @EnvironmentObject var gameState: GameState

    private var coins: Int {
        gameState.wallet?.coins ?? 0
    }

    private var crystals: Int {
        gameState.wallet?.crystals ?? 0
    }

    private var shards: Int {
        gameState.wallet?.shards ?? 0
    }

    var body: some View {
        HStack {
            Spacer()

            HStack(spacing: 20) {
                currencyView(
                    icon: "icon_coin",
                    value: coins,
                    accent: .yellow
                )

                currencyView(
                    icon: "icon_crystal",
                    value: crystals,
                    accent: .cyan
                )

                currencyView(
                    icon: "icon_shard",
                    value: shards,
                    accent: .orange
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.65))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Currency View
    private func currencyView(
        icon: String,
        value: Int,
        accent: Color
    ) -> some View {

        HStack(spacing: 6) {

            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)

            Text("\(value)")
                .font(.system(size: 16, weight: .heavy))
                .monospacedDigit()
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accent.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(
            color: accent.opacity(0.25),
            radius: 6,
            y: 2
        )
    }
}
