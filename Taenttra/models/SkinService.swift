//
//  SkinService.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Combine
import Foundation

final class SkinService {

    static func buy(
        skin: SkinItem,
        wallet: PlayerWallet
    ) -> Bool {

        guard !wallet.ownedSkins.contains(skin.id) else {
            equip(skin: skin, wallet: wallet)
            return true
        }

        switch skin.currency {
        case .coins:
            guard wallet.coins >= skin.price else { return false }
            wallet.coins -= skin.price

        case .crystals:
            guard wallet.crystals >= skin.price else { return false }
            wallet.crystals -= skin.price
        }

        wallet.ownedSkins.append(skin.id)
        wallet.equippedSkin = skin.id
        return true
    }

    static func equip(
        skin: SkinItem,
        wallet: PlayerWallet
    ) {
        guard wallet.ownedSkins.contains(skin.id) else { return }
        wallet.equippedSkin = skin.id
    }
}
