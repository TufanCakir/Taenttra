//
//  WalletHUD.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftData
import SwiftUI

struct WalletHUD: View {

    @Query private var wallets: [PlayerWallet]

    private var coins: Int { wallets.first?.coins ?? 0 }
    private var crystals: Int { wallets.first?.crystals ?? 0 }

    var body: some View {
        HStack(spacing: 12) {

            walletItem(icon: "icon_coin", value: coins)
            walletItem(icon: "icon_crystal", value: crystals)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Wallet Item
    private func walletItem(icon: String, value: Int) -> some View {
        HStack(spacing: 6) {

            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text("\(value)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

#Preview {
    WalletHUD()
}
