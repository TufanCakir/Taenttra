//
//  FighterAnimation.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

enum FighterAnimation: String {
    case idle
    case punch
    case kick
    case ko
}

enum FighterSide {
    case left
    case right
}

enum FightState {
    case fighting
    case ko
    case victory
    case timeout  // 🆕
}

extension FighterAnimation {
    var characterState: CharacterState {
        switch self {
        case .idle: return .idle
        case .punch: return .punch
        case .kick: return .kick
        case .ko: return .idle  // 🔁 KO nutzt idle Sprite
        }
    }
}
