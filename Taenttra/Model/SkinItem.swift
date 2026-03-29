//
//  SkinItem.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

struct SkinItem: Codable, Identifiable {
    let id: String
    let name: String
    let previewImage: String
    let fighterSprite: String
    let price: Int
    let currency: Currency
}
