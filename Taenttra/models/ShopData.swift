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

struct ShopItem: Codable, Identifiable {
    let id: String
    let name: String
    let price: Int
    let currency: Currency
    let preview: String
}

enum Currency: String, Codable {
    case coins
    case crystals
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
