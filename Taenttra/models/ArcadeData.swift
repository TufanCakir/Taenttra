//
//  ArcadeData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Foundation

struct ArcadeData: Codable {
    let stages: [ArcadeStage]
}

struct ArcadeStage: Codable, Identifiable {
    let id: String
    let name: String
    let background: String
    let music: String
    let waves: [ArcadeWave]
}

struct ArcadeWave: Codable, Identifiable {
    let wave: Int
    let enemyPool: [String]
    let enemyCount: Int
    let timeLimit: Int
    var id: Int { wave }
}

final class ArcadeLoader {

    static func load() -> ArcadeData {
        guard
            let url = Bundle.main.url(
                forResource: "arcade_stages",
                withExtension: "json"
            )
        else {
            fatalError("❌ arcade_stages.json missing")
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ArcadeData.self, from: data)
        } catch {
            fatalError("❌ arcade json decode failed: \(error)")
        }
    }
}
