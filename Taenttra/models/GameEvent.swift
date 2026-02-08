//
//  GameEvent.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

struct GameEvent: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let gridColor: String
    let bosses: [EventBoss]
    let category: EventCategory
    let musicIndex: Int?      // 👈 NEU
    
    // ⏰ ZEITSTEUERUNG (NEU)
       let startDate: Date?
       let endDate: Date?
}

enum EventCategory: String, Codable, CaseIterable {
    case raid
    case trial
    case special
}

struct EventBoss: Codable, Identifiable {
    var id: String { modelNames.joined(separator: "_") }

    let modelNames: [String]

    let hp: EventValue
    let coins: EventValue
    let crystals: EventValue
    let exp: EventValue
}

enum EventValue: Codable {
    case single(Int)
    case multi([Int])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Int.self) {
            self = .single(v)
        } else if let arr = try? container.decode([Int].self) {
            self = .multi(arr)
        } else {
            throw DecodingError.typeMismatch(
                EventValue.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Int or [Int]"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let v): try container.encode(v)
        case .multi(let arr): try container.encode(arr)
        }
    }

    func value(at index: Int) -> Int {
        switch self {
        case .single(let v):
            return v

        case .multi(let arr):
            return arr[min(index, arr.count - 1)]
        }
    }
}

enum EventLoader {

    static func loadEvents() -> [GameEvent] {
        guard
            let url = Bundle.main.url(forResource: "events", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            print("❌ events.json konnte nicht geladen werden")
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let events = try decoder.decode([GameEvent].self, from: data)
            return events
        } catch {
            print("❌ Fehler beim Decoden der Events:", error)
            return []
        }
    }

    static func event(id: String) -> GameEvent? {
        loadEvents().first { $0.id == id }
    }
}

extension GameEvent {
    var isActive: Bool {
        let now = Date()

        if let start = startDate, now < start { return false }
        if let end = endDate, now > end { return false }

        return true
    }
}
