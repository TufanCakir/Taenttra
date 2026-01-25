//
//  TrainingData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation

struct TrainingData: Decodable {
    let modes: [TrainingMode]
}

struct TrainingMode: Decodable, Identifiable {
    let id: String
    let title: String
    let background: String
    let music: String
    let enemy: String
    let timeLimit: Int
}

final class TrainingLoader {

    static func load() -> TrainingData {
        guard
            let url = Bundle.main.url(
                forResource: "training",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(
                TrainingData.self,
                from: data
            )
        else {
            fatalError("❌ training.json missing or invalid")
        }
        return decoded
    }
}
