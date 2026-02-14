//
//  Player.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct Player: Codable, Identifiable {
    let id: String
    let name: String
    var level: Int
    var exp: Int
    var expToNextLevel: Int
    let attack: Int
}
