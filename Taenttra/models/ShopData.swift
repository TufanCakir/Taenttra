//
//  ShopData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation

struct ShopData: Codable {
    let categories: [ShopCategory]
}

struct ShopCategory: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let items: [ShopItem]
}

struct ShopTab: Identifiable, Hashable {
    let currency: Currency
    let title: String
    let icon: String

    var id: String { currency.rawValue }
}

struct ShopItem: Codable, Identifiable {

    let id: UUID  // SwiftUI
    let skinId: String  // Gameplay-ID

    let name: String
    let price: Int
    let currency: Currency
    let preview: String
    let spriteSkinId: String?

    init(
        id: UUID = UUID(),
        skinId: String,
        name: String,
        price: Int,
        currency: Currency,
        preview: String,
        spriteSkinId: String? = nil
    ) {
        self.id = id
        self.skinId = skinId
        self.name = name
        self.price = price
        self.currency = currency
        self.preview = preview
        self.spriteSkinId = spriteSkinId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.skinId = try container.decode(String.self, forKey: .skinId)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decode(Int.self, forKey: .price)
        self.currency = try container.decode(Currency.self, forKey: .currency)
        self.preview = try container.decode(String.self, forKey: .preview)
        self.spriteSkinId = try container.decodeIfPresent(
            String.self,
            forKey: .spriteSkinId
        )
    }

    private enum CodingKeys: String, CodingKey {
        case skinId, name, price, currency, preview, spriteSkinId
    }
}

enum Currency: String, Codable {
    case coins
    case crystals
    case tournamentShards  // 🏆 EVENT-WÄHRUNG
}

extension ShopItem {
    var isSkin: Bool { true }  // später erweiterbar
}

final class ShopLoader {
    static func load() -> ShopData {
        guard
            let url = Bundle.main.url(
                forResource: "shop",
                withExtension: "json"
            )
        else {
            fatalError("shop.json not found")
        }

        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(ShopData.self, from: data)
    }
}
