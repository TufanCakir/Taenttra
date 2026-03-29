//
//  ShopData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
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

    let id: UUID
    let type: ShopItemType   // 🔥 NEU

    let skinId: String?
    let amount: Int?         // 🔥 für Currency Packs

    let name: String
    let price: Int?
    let currency: Currency
    let preview: String
    let productId: String?

    init(
        id: UUID = UUID(),
        type: ShopItemType,
        skinId: String? = nil,
        amount: Int? = nil,
        name: String,
        price: Int,
        currency: Currency,
        preview: String,
        productId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.skinId = skinId
        self.amount = amount
        self.name = name
        self.price = price
        self.currency = currency
        self.preview = preview
        self.productId = productId
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case skinId
        case amount
        case name
        case price
        case currency
        case preview
        case productId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // id may be missing in JSON, generate one if absent
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.type = try container.decode(ShopItemType.self, forKey: .type)
        self.skinId = try container.decodeIfPresent(String.self, forKey: .skinId)
        self.amount = try container.decodeIfPresent(Int.self, forKey: .amount)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Int.self, forKey: .price)
        self.currency = try container.decode(Currency.self, forKey: .currency)
        self.preview = try container.decode(String.self, forKey: .preview)
        self.productId = try container.decodeIfPresent(String.self, forKey: .productId)
    }
}

enum ShopItemType: String, Codable {
    case skin
    case currency
}

enum Currency: String, Codable {
    case coins
    case crystals
    case shards
    case realMoney
}

extension ShopItem {
    var isSkin: Bool { type == .skin }
}

final class ShopLoader {
    static func load() -> ShopData {
        guard
            let url = Bundle.main.url(
                forResource: "shop",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(ShopData.self, from: data)
        else {
            return ShopData(categories: [])
        }

        return decoded
    }
}
