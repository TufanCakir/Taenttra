//
//  SummonBanner.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct SummonBanner: Identifiable {
    let id: String
    let title: String
    let description: String
    let image: String
    let singleCost: Int
    let multiCost: Int
    let rates: [String: Double]
    let pool: [SummonUnit]
}

struct SummonUnit {
    let id: String
    let rarity: String
}
