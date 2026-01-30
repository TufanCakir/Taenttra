//
//  VersusHeaderView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct VersusHeaderView: View {

    @EnvironmentObject var gameState: GameState

    var body: some View {
        HStack {
            Spacer()

            HStack(spacing: 40) {
                currencyView(
                    icon: "icon_coin",
                    value: gameState.wallet.coins
                )

                currencyView(
                    icon: "icon_crystal",
                    value: gameState.wallet.crystals
                )
                currencyView(
                    icon: "icon_tournament",
                    value: gameState.wallet.tournamentShards
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Currency View
    private func currencyView(icon: String, value: Int) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
    }
}
