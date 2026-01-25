//
//  ShopItemRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI
import UIKit

struct ShopItemRow: View {

    @State private var showConfirm = false

    let item: ShopItem
    let wallet: PlayerWallet

    var body: some View {

        HStack(spacing: 12) {

            Image(item.preview)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                priceView
            }

            Spacer()

            actionButton
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .confirmationDialog(
            "Confirm Purchase",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button(
                "Buy • \(item.price) \(item.currency == .coins ? "Coins" : "Crystals")"
            ) {
                buy()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Price View (Systemfarben)

    private var priceView: some View {
        HStack(spacing: 6) {

            Image(priceIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)

            Text("\(item.price)")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private var priceIcon: String {
        switch item.currency {
        case .coins:
            return "icon_coin"
        case .crystals:
            return "icon_crystal"
        }
    }

    // MARK: - Button

    private var actionButton: some View {
        Group {
            if wallet.ownedSkins.contains(item.id) {
                equipButton
            } else {
                buyButton
            }
        }
    }

    private var buyButton: some View {
        Button("Buy") {
            showConfirm = true
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(.borderedProminent)
    }

    private var equipButton: some View {
        Button(
            wallet.equippedSkin == item.id ? "Equipped" : "Equip"
        ) {
            wallet.equippedSkin = item.id
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(.bordered)
        .disabled(wallet.equippedSkin == item.id)
    }

    // MARK: - Buy Logic

    private func buy() {
        switch item.currency {
        case .coins:
            guard wallet.coins >= item.price else { return }
            wallet.coins -= item.price

        case .crystals:
            guard wallet.crystals >= item.price else { return }
            wallet.crystals -= item.price
        }

        if !wallet.ownedSkins.contains(item.id) {
            wallet.ownedSkins.append(item.id)
        }
        wallet.equippedSkin = item.id
    }
}
