//
//  ShopCategory.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct ShopCategory: Identifiable {
    let id: String
    let title: String
    let icon: String
    let items: [ShopItemModel]
}

struct ShopItemModel: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: String
    let productId: String
    let image: String
}

