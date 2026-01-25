//
//  EventData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation

struct EventData: Decodable {
    let events: [EventMode]
}

struct EventMode: Decodable, Identifiable {
    let id: String
    let title: String
    let background: String
    let music: String
    let enemy: String
    let timeLimit: Int
    let expiresAt: String  // später Date
}

final class EventLoader {

    static func load() -> EventData {
        guard
            let url = Bundle.main.url(
                forResource: "events",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(EventData.self, from: data)
        else {
            fatalError("❌ events.json missing or invalid")
        }

        return decoded
    }
}
