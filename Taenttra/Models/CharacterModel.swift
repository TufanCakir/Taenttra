//
//  CharacterModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct Character: Identifiable, Codable {
    let id: String
    let name: String
    let image: String
    let rarity: String
}
