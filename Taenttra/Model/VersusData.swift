//
//  VersusData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

struct VersusData: Codable {
    let stages: [VersusStage]
}

struct VersusStage: Codable, Identifiable {
    let id: String
    let name: String
    let background: String
    let music: String
    let waves: [VersusWave]
}

struct VersusWave: Codable, Identifiable {
    let wave: Int
    let enemies: [String]
    let timeLimit: Int

    var id: Int { wave }
}

final class VersusLoader {
    static func load() -> VersusData {
        guard
            let url = Bundle.main.url(
                forResource: "versus_stages",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(VersusData.self, from: data)
        else {
            return VersusData(stages: [])
        }

        return decoded
    }
}
