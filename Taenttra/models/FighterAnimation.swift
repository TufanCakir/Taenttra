//
//  FighterAnimation.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
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
}
