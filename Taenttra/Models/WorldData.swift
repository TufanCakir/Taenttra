//
//  WorldData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct WorldData: Codable {
    let dimensions: [Dimension]
}

struct Dimension: Codable, Identifiable {
    let id: String
    let background: String
    let stages: [Stage]
    let islands: [Island]
}

struct Stage: Codable, Identifiable {
    let id: Int
    let name: String
    let islandIds: [String]
}

struct Island: Codable, Identifiable {
    let id: String
    let image: String
    let x: CGFloat
    let y: CGFloat
    let unlockAfterIslandId: String?
    let levels: [Level]
}


struct Level: Codable, Identifiable {
    let id: String
    let number: Int
    let x: CGFloat
    let y: CGFloat
    let unlockAfter: String?
}
