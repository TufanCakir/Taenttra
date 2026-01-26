//
//  ShopItemRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

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
            Button(confirmTitle, action: buy)
                .disabled(!canAfford)

            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - State

    private var isOwned: Bool {
        wallet.ownedSkins.contains(item.skinId)
    }

    private var isEquipped: Bool {
        wallet.equippedSkin == item.skinId
    }

    private var canAfford: Bool {
        switch item.currency {
        case .coins:
            return wallet.coins >= item.price
        case .crystals:
            return wallet.crystals >= item.price
        }
    }

    private var confirmTitle: String {
        "Buy • \(item.price) \(item.currency == .coins ? "Coins" : "Crystals")"
    }

    // MARK: - Price

    private var priceView: some View {
        HStack(spacing: 6) {
            Image(item.currency == .coins ? "icon_coin" : "icon_crystal")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)

            Text("\(item.price)")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundColor(canAfford ? .secondary : .red)
        }
    }

    // MARK: - Buttons

    private var actionButton: some View {
        Group {
            if isOwned {
                equipButton
            } else {
                buyButton
            }
        }
    }

    private var currencyName: String {
        item.currency == .coins ? "Coins" : "Crystals"
    }

    private var buyButton: some View {
        Button {
            if canAfford {
                showConfirm = true
            }
        } label: {
            Text(canAfford ? "Buy" : "Not enough \(currencyName)")
                .font(.caption.weight(.semibold))
                .frame(minWidth: 90)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(canAfford ? Color.cyan : Color.gray.opacity(0.3))
                )
                .foregroundColor(.black)
        }
    }

    private var equipButton: some View {
        Button(isEquipped ? "Equipped" : "Equip") {
            equip()
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(.bordered)
        .disabled(isEquipped)
    }

    // MARK: - Logic

    private func buy() {
        guard !isOwned, canAfford else { return }

        switch item.currency {
        case .coins:
            wallet.coins -= item.price
        case .crystals:
            wallet.crystals -= item.price
        }

        wallet.ownedSkins.append(item.skinId)
        wallet.equippedSkin = item.skinId
    }

    private func equip() {
        guard isOwned else { return }
        wallet.equippedSkin = item.skinId
    }
}
