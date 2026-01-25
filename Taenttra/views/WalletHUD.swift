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
        .scaledToFit()
        .frame(width: 20, height: 20)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
                )
                .blur(radius: 0.5)
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
    
    // MARK: - Subview
    private func walletItem(icon: String, value: Int) -> some View {
        HStack(spacing: 6) {
            
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
            
            Text("\(value)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.4))
        )
    }
}
