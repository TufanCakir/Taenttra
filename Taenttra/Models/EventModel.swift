//
//  EventModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct EventModel: Codable, Identifiable {
    let id: String
    let title: String
    let image: String
    let difficulty: Int
    let world: String
    let staminaCost: Int
}

