//
//  DailyReward.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

struct DailyReward: Identifiable {
    let id = UUID().uuidString
    let day: Int
    let title: String
    let coins: Int?
    let crystals: Int?
}
