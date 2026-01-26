//
//  VersusHeaderView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct VersusHeaderView: View {

    @ObservedObject private var coinManager = CoinManager.shared
    @ObservedObject private var crystalManager = CrystalManager.shared

    var body: some View {
        HStack {
            Spacer()

            HStack(spacing: 50) {
                currencyView(
                    icon: "icon_coin",
                    value: coinManager.coins
                )

                currencyView(
                    icon: "icon_crystal",
                    value: crystalManager.crystals
                )
            }
        }
        .padding()
    }

    // MARK: - Currency Item
    private func currencyView(icon: String, value: Int) -> some View {
        HStack(spacing: 10) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text("\(value)")
                .font(.system(size: 20, weight: .bold))
                .monospacedDigit()
        }
    }

}

#Preview {
    VersusHeaderView()
}
