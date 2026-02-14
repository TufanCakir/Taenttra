//
//  ExchangeCategory.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct ExchangeCategory: Identifiable {
    let id: String
    let title: String
    let icon: String
    let items: [ExchangeItem]
}

struct ExchangeItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let cost: Int
    let currency: String
    let image: String
}

