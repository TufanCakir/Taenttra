//
//  SkinService.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

enum SkinService {
    static func buy(
        skin: SkinItem,
        wallet: PlayerWallet
    ) -> Bool {
        guard !isOwned(skin, in: wallet) else {
            equip(skin: skin, wallet: wallet)
            return true
        }

        guard spend(price: skin.price, currency: skin.currency, from: wallet) else {
            return false
        }

        wallet.ownedSkins.append(skin.id)
        wallet.equippedSkin = skin.id
        return true
    }

    static func equip(
        skin: SkinItem,
        wallet: PlayerWallet
    ) {
        guard isOwned(skin, in: wallet) else { return }
        wallet.equippedSkin = skin.id
    }

    private static func isOwned(
        _ skin: SkinItem,
        in wallet: PlayerWallet
    ) -> Bool {
        wallet.ownedSkins.contains(skin.id)
    }

    private static func spend(
        price: Int,
        currency: Currency,
        from wallet: PlayerWallet
    ) -> Bool {
        switch currency {
        case .coins:
            guard wallet.coins >= price else { return false }
            wallet.coins -= price
        case .crystals:
            guard wallet.crystals >= price else { return false }
            wallet.crystals -= price
        case .shards:
            guard wallet.shards >= price else { return false }
            wallet.shards -= price
        case .realMoney:
            return false
        }

        return true
    }
}
