//
//  HomeMenuItem.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

enum HomeMenuItem: CaseIterable {
    case story
    case arcade
    case survival
    case events
    case versus
    case training
    case options

    var title: String {
        switch self {
        case .story: return "STORY"
        case .versus: return "VERSUS"
        case .arcade: return "ARCADE"
        case .survival: return "SURVIVAL"
        case .events: return "EVENTS"
        case .training: return "TRAINING"
        case .options: return "OPTIONS"
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
        case .options: return .gray
        }
    }
}
