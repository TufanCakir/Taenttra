//
//  EventModeUI.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

struct EventModeUI: Decodable {
    let buttonColor: String
    let overlayColor: String
    let overlayOpacity: Double
}

struct EventCategory: Decodable, Identifiable {
    let id: String
    let title: String
    let ui: EventModeUI
}

private struct EventModeContainer: Decodable {
    let modes: [EventCategory]
}

final class EventModeLoader {
    static func load() -> [EventCategory] {
        guard
            let url = Bundle.main.url(
                forResource: "event_modes",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(EventModeContainer.self, from: data)
        else {
            return []
        }

        return decoded.modes
    }
}
