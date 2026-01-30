//
//  VersusData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
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
    let enemies: [String]  // character keys
    let timeLimit: Int

    var id: Int { wave }
}

final class VersusLoader {

    static func load() -> VersusData {
        print("🟡 VersusLoader.load() called")

        guard
            let url = Bundle.main.url(
                forResource: "versus_stages",
                withExtension: "json"
            )
        else {
            fatalError("❌ versu_waves.json NOT FOUND in bundle")
        }

        print("🟢 Found JSON at:", url)

        do {
            let data = try Data(contentsOf: url)
            print("🟢 Loaded JSON data (\(data.count) bytes)")

            let decoded = try JSONDecoder().decode(VersusData.self, from: data)
            print("🟢 Decoded VersusData with \(decoded.stages.count) stages")

            return decoded
        } catch {
            fatalError("❌ Failed to decode versus_waves.json: \(error)")
        }
    }
}
