//
//  GameEvent.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct GameEvent: Identifiable {
    let id: String
    let title: String
    let description: String
    let image: String
    let startDate: Date
    let endDate: Date
    let currency: EventCurrency
    let bonusMultiplier: Double
    let world: String
    let isRaidEvent: Bool
}

struct EventCurrency {
    let id: String
    let name: String
    let icon: String
}

