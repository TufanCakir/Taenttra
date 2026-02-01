//
//  EventModeUI.swift
//  Taenttra
//
//  Created by Tufan Cakir on 01.02.26.
//

import Foundation

struct EventModeUI: Decodable {
    let buttonColor: String
    let overlayColor: String
    let overlayOpacity: Double
}

struct EventCategory: Decodable, Identifiable {
    let id: String  // "normal", "special", "boss"
    let title: String
    let ui: EventModeUI
}

final class EventModeLoader {
    static func load() -> [EventCategory] {
        let url = Bundle.main.url(
            forResource: "event_modes",
            withExtension: "json"
        )!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(
            [String: [EventCategory]].self,
            from: data
        )["modes"]!
    }
}
