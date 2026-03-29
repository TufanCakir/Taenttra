//
//  BackgroundThemeData.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import Foundation
import SwiftUI

struct BackgroundThemeCatalog: Codable {
    let defaultThemeID: String
    let themes: [BackgroundTheme]
}

struct BackgroundTheme: Codable, Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let rarity: BackgroundThemeRarity
    let unlockSource: BackgroundThemeUnlockSource
    let kind: BackgroundThemeKind
    let effectStyle: BackgroundThemeEffect
    let premiumEffect: PremiumBackgroundEffect?
    let imageAssetName: String?
    let topHex: String
    let bottomHex: String
    let glowHex: String
    let secondaryGlowHex: String
    let accentHex: String
    let imageOpacity: Double
    let meshOpacity: Double
    let detailCount: Int

    var topColor: Color { Color(hex: topHex) }
    var bottomColor: Color { Color(hex: bottomHex) }
    var glowColor: Color { Color(hex: glowHex) }
    var secondaryGlowColor: Color { Color(hex: secondaryGlowHex) }
    var accentColor: Color { Color(hex: accentHex) }
}

enum BackgroundThemeRarity: String, Codable {
    case common
    case rare
    case premium
    case legendary

    var title: String {
        rawValue.uppercased()
    }

    var chipColor: Color {
        switch self {
        case .common:
            return .white
        case .rare:
            return .cyan
        case .premium:
            return .orange
        case .legendary:
            return .pink
        }
    }
}

enum BackgroundThemeUnlockSource: String, Codable {
    case shop
    case seasonPass = "season_pass"
    case eventMission = "event_mission"

    var title: String {
        switch self {
        case .shop:
            return "SHOP"
        case .seasonPass:
            return "SEASON PASS"
        case .eventMission:
            return "EVENT MISSION"
        }
    }

    var accentColor: Color {
        switch self {
        case .shop:
            return .yellow
        case .seasonPass:
            return .green
        case .eventMission:
            return .pink
        }
    }

    var targetScreen: GameScreen {
        switch self {
        case .shop:
            return .shop
        case .seasonPass:
            return .season
        case .eventMission:
            return .missiona
        }
    }
}

enum BackgroundThemeKind: String, Codable {
    case generated
    case asset
}

enum BackgroundThemeEffect: String, Codable {
    case grid
    case rings
    case beams
    case shards
    case halo
}

enum PremiumBackgroundEffect: String, Codable {
    case starfield
    case sparks
    case lightning
}

enum BackgroundThemeLoader {
    static func load() -> BackgroundThemeCatalog {
        guard
            let url = Bundle.main.url(forResource: "backgrounds", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(BackgroundThemeCatalog.self, from: data)
        else {
            return fallbackCatalog
        }

        return decoded
    }

    private static var fallbackCatalog: BackgroundThemeCatalog {
        BackgroundThemeCatalog(
            defaultThemeID: "theme_default",
            themes: [
                BackgroundTheme(
                    id: "theme_default",
                    name: "Default Gate",
                    subtitle: "Core neon arena.",
                    rarity: .common,
                    unlockSource: .shop,
                    kind: .generated,
                    effectStyle: .grid,
                    premiumEffect: nil,
                    imageAssetName: nil,
                    topHex: "#050815",
                    bottomHex: "#120B28",
                    glowHex: "#23D6FF",
                    secondaryGlowHex: "#FF4BA8",
                    accentHex: "#FFE34D",
                    imageOpacity: 0,
                    meshOpacity: 0.16,
                    detailCount: 6
                )
            ]
        )
    }
}

enum BackgroundThemeService {
    static func theme(for id: String?) -> BackgroundTheme {
        let catalog = BackgroundThemeLoader.load()
        let resolvedID = id ?? catalog.defaultThemeID

        return catalog.themes.first(where: { $0.id == resolvedID })
            ?? catalog.themes.first(where: { $0.id == catalog.defaultThemeID })
            ?? BackgroundThemeLoader.load().themes[0]
    }

    static func isOwned(themeID: String, wallet: PlayerWallet) -> Bool {
        let defaultThemeID = BackgroundThemeLoader.load().defaultThemeID
        return themeID == defaultThemeID || wallet.ownedBackgroundThemeIDs.contains(themeID)
    }

    static func isEquipped(themeID: String, wallet: PlayerWallet) -> Bool {
        wallet.selectedBackgroundThemeID == themeID
    }

    static func canBuy(_ theme: BackgroundTheme) -> Bool {
        theme.unlockSource == .shop
    }

    static func buy(
        themeID: String,
        price: Int,
        currency: Currency,
        wallet: PlayerWallet
    ) -> Bool {
        guard !isOwned(themeID: themeID, wallet: wallet) else {
            equip(themeID: themeID, wallet: wallet)
            return true
        }

        guard spend(price: price, currency: currency, from: wallet) else {
            return false
        }

        wallet.ownedBackgroundThemeIDs.append(themeID)
        wallet.selectedBackgroundThemeID = themeID
        return true
    }

    static func unlock(themeID: String, wallet: PlayerWallet) {
        guard !wallet.ownedBackgroundThemeIDs.contains(themeID) else {
            equip(themeID: themeID, wallet: wallet)
            return
        }

        wallet.ownedBackgroundThemeIDs.append(themeID)
        wallet.selectedBackgroundThemeID = themeID
    }

    static func equip(themeID: String, wallet: PlayerWallet) {
        guard isOwned(themeID: themeID, wallet: wallet) else { return }
        wallet.selectedBackgroundThemeID = themeID
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
