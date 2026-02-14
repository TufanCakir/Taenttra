//
//  Enemy.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct Enemy: Codable, Identifiable {
    let id: String
    let name: String
    var hp: Int
    let attack: Int
    let coinDrop: Int
    let expDrop: Int
}
