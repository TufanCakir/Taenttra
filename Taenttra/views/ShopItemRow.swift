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

    private var isEventItem: Bool {
        item.currency == .tournamentShards
    }

    var body: some View {

        HStack(spacing: 14) {

            // 🖼 Preview
            Image(item.preview)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemBackground))
                )

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.headline)

                    if isEventItem {
                        tag("EVENT")
                    }
                }

                priceView
            }

            Spacer()

            actionButton
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay {
                    if isEventItem {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                    }
                }
        )
        .confirmationDialog(
            "Confirm Purchase",
            isPresented: $showConfirm
        ) {
            Button(confirmTitle, action: buy)
                .disabled(!canAfford)

            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Price

    private var priceView: some View {
        HStack(spacing: 6) {

            Image(currencyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)

            Text("\(item.price)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    isEventItem
                        ? Color.yellow.opacity(0.2)
                        : Color(.tertiarySystemBackground)
                )
        )
        .foregroundColor(canAfford ? .primary : .red)
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

    private var buyButton: some View {
        Button {
            if canAfford {
                showConfirm = true
            }
        } label: {
            Text(canAfford ? "BUY" : "NOT ENOUGH")
                .font(.caption.weight(.bold))
                .frame(minWidth: 90)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            canAfford
                                ? (isEventItem ? Color.yellow : Color.cyan)
                                : Color.gray.opacity(0.3)
                        )
                )
                .foregroundColor(.black)
        }
    }

    private var equipButton: some View {
        Button(isEquipped ? "EQUIPPED" : "EQUIP") {
            equip()
        }
        .font(.caption.weight(.bold))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .stroke(Color.cyan, lineWidth: 1.5)
        )
        .foregroundColor(.cyan)
        .disabled(isEquipped)
        .opacity(isEquipped ? 0.6 : 1)
    }

    // MARK: - Helpers

    private var currencyIcon: String {
        switch item.currency {
        case .coins: return "icon_coin"
        case .crystals: return "icon_crystal"
        case .tournamentShards: return "icon_tournament"
        }
    }

    private var confirmTitle: String {
        "Buy • \(item.price) \(currencyName)"
    }

    private var currencyName: String {
        switch item.currency {
        case .coins: return "Coins"
        case .crystals: return "Crystals"
        case .tournamentShards: return "Tournament Shards"
        }
    }

    private var canAfford: Bool {
        switch item.currency {
        case .coins: return wallet.coins >= item.price
        case .crystals: return wallet.crystals >= item.price
        case .tournamentShards: return wallet.tournamentShards >= item.price
        }
    }

    private var isOwned: Bool {
        wallet.ownedSkins.contains(item.skinId)
    }

    private var isEquipped: Bool {
        wallet.equippedSkin == item.skinId
    }

    private func buy() {
        guard !isOwned, canAfford else { return }

        switch item.currency {
        case .coins: wallet.coins -= item.price
        case .crystals: wallet.crystals -= item.price
        case .tournamentShards: wallet.tournamentShards -= item.price
        }

        wallet.ownedSkins.append(item.skinId)
        wallet.equippedSkin = item.skinId
    }

    private func equip() {
        guard isOwned else { return }
        wallet.equippedSkin = item.skinId
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.yellow.opacity(0.8))
            )
            .foregroundColor(.black)
    }
}
