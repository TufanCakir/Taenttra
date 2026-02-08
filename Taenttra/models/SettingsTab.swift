//
//  SettingsTab.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import Foundation

enum SettingsTab: String, CaseIterable, Identifiable {
    case appearance
    case behavior
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .appearance: return "Appearance"
        case .behavior: return "Behavior"
        case .about: return "About"
        }
    }
}
