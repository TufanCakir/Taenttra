//
//  BackgroundStyle.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

enum BackgroundStyle: String, CaseIterable, Identifiable, Codable {

    case blueGrid
    case redGrid
    case purpleGrid
    case emeraldGrid
    case raidPNG
    case background8PNG

    var id: String { rawValue }

    var isPNG: Bool {
        imageName.isEmpty == false
    }

    var imageName: String {
        switch self {
        case .raidPNG: return "raid_bg"
        case .background8PNG: return "background8"
        default: return ""
        }
    }

    var glowColor: Color {
        switch self {
        case .blueGrid: return .blue
        case .redGrid: return .red
        case .purpleGrid: return .purple
        case .emeraldGrid: return .green
        default: return .blue
        }
    }
}
