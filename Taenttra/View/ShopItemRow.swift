//
//  ShopItemRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ShopItemRow: View {
    @State private var showConfirm = false

    let item: ShopItem
    let wallet: PlayerWallet

    private var isEventItem: Bool {
        item.currency == .shards
    }

    private var isOwned: Bool {
        guard let id = item.skinId else { return false }
        return wallet.ownedSkins.contains(id)
    }

    private var isEquipped: Bool {
        guard let id = item.skinId else { return false }
        return wallet.equippedSkin == id
    }

    private var canAfford: Bool {
        guard item.productId == nil else { return true }

        switch item.currency {
        case .coins:
            return wallet.coins >= item.price ?? 0
        case .crystals:
            return wallet.crystals >= item.price ?? 0
        case .shards:
            return wallet.shards >= item.price ?? 0
        case .realMoney:
            return false
        }
    }

    private var confirmTitle: String {
        "Buy • \(item.price ?? 0) \(currencyName)"
    }

    private var currencyName: String {
        switch item.currency {
        case .coins:
            return "Coins"
        case .crystals:
            return "Crystals"
        case .shards:
            return "Shards"
        case .realMoney:
            return "Premium"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
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

    private var priceView: some View {
        HStack(spacing: 6) {
            Image(currencyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            if let amount = item.amount {
                Text("+\(amount)")
                    .foregroundStyle(.cyan)
            } else {
                Text("\(item.price ?? 0)")
            }
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
        .foregroundStyle(canAfford ? Color.primary : Color.red)
    }

    private var actionButton: some View {
        Group {
            if isEquipped {
                statusBadge("EQUIPPED", color: .cyan)
            } else if isOwned {
                statusBadge("OWNED", color: .secondary)
            } else {
                buyButton
            }
        }
    }

    private func statusBadge(
        _ text: String,
        color: Color
    ) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
            .foregroundStyle(color)
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
                .foregroundStyle(.black)
        }
    }

    private var currencyIcon: String {
        switch item.currency {
        case .coins:
            return "icon_coin"
        case .crystals:
            return "icon_crystal"
        case .shards:
            return "icon_shard"
        case .realMoney:
            return "icon_crystal"
        }
    }

    private func buy() {
        guard !isOwned, canAfford, let skin = skinItem else { return }
        _ = SkinService.buy(skin: skin, wallet: wallet)
    }

    private var skinItem: SkinItem? {
        guard
            item.type == .skin,
            let skinId = item.skinId,
            let price = item.price
        else {
            return nil
        }

        return SkinItem(
            id: skinId,
            name: item.name,
            previewImage: item.preview,
            fighterSprite: skinId,
            price: price,
            currency: item.currency
        )
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
            .foregroundStyle(.black)
    }
}
