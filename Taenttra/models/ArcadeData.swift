//
//  ArcadeData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Foundation

struct ArcadeData: Decodable {
    let stages: [ArcadeStage]
}

struct ArcadeStage: Decodable, Identifiable {
    let id: String
    let title: String
    let background: String
    let music: String
    let enemy: String
    let waves: Int
}

final class ArcadeLoader {

    static func load() -> ArcadeData {
        guard
            let url = Bundle.main.url(
                forResource: "arcade",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(ArcadeData.self, from: data)
        else {
            fatalError("❌ arcade.json missing or invalid")
        }

        return decoded
    }
}
