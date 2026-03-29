//
//  HomeMenuItem.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

enum HomeMenuItem: CaseIterable {
    case story
    case arcade
    case survival
    case events
    case versus
    case training
    case summon
    case shop
    case skin
    case options

    /// Muss dieser Modus durch Story freigeschaltet werden?
    var requiredStorySectionId: String? {
        switch self {
        case .training: return "1_2"
        case .arcade: return "1_3"
        case .versus: return "1_4"
        case .events: return "1_5"
        case .survival: return "1_6"

        // ✅ Meta & Kosmetik IMMER frei
        case .shop, .skin, .story, .options, .summon:
            return nil
        }
    }

    // MARK: - Display

    var title: String {
        switch self {
        case .story: return "Story"
        case .versus: return "Versus"
        case .arcade: return "Arcade"
        case .survival: return "Survival"
        case .events: return "Events"
        case .training: return "Training"
        case .summon: return "Summon"
        case .shop: return "Shop"
        case .skin: return "Skin"
        case .options: return "Options"
        }
    }

    var color: Color {
        switch self {
        case .story: return .blue
        case .arcade: return .orange
        case .survival: return .indigo
        case .events: return .purple
        case .versus: return .red
        case .training: return .green
        case .summon: return .pink
        case .shop: return .yellow
        case .skin: return .cyan
        case .options: return .gray
        }
    }

    // MARK: - Navigation Target

    var screen: GameScreen {
        switch self {
        case .story: return .story
        case .arcade: return .arcade
        case .survival: return .survival
        case .events: return .events
        case .training: return .training
        case .summon: return .summon
        case .shop: return .shop
        case .skin: return .skin
        case .options: return .options

        case .versus:
            return .versus
        }
    }

    // MARK: - Unlock Rules

    /// Nur Story ist am Anfang freigeschaltet
    var unlockedByDefault: Bool {
        self == .story
    }
}
