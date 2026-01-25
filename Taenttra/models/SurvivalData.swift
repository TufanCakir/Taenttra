//
//  SurvivalData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation

struct SurvivalData: Decodable {
    let modes: [SurvivalMode]
}

struct SurvivalMode: Decodable, Identifiable {
    let id: String
    let title: String
    let background: String
    let music: String
    let enemyPool: [String]
    let timeLimit: Int
}

final class SurvivalLoader {

    static func load() -> SurvivalData {
        guard
            let url = Bundle.main.url(forResource: "survival", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(SurvivalData.self, from: data)
        else {
            fatalError("❌ survival.json missing or invalid")
        }

        return decoded
    }
}
