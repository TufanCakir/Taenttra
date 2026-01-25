//
//  CharacterDisplay.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Foundation

struct CharacterDisplay: Identifiable, Codable {
    var id: UUID?
    let key: String
    let displayImage: String
    let name: String
    let locked: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case displayImage
        case name
        case locked
    }

    init(
        id: UUID? = nil,
        key: String,
        displayImage: String,
        name: String,
        locked: Bool
    ) {
        self.id = id ?? UUID()
        self.key = key
        self.displayImage = displayImage
        self.name = name
        self.locked = locked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.id = decodedId ?? UUID()
        self.key = try container.decode(String.self, forKey: .key)
        self.displayImage = try container.decode(
            String.self,
            forKey: .displayImage
        )
        self.name = try container.decode(String.self, forKey: .name)
        self.locked = try container.decode(Bool.self, forKey: .locked)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(displayImage, forKey: .displayImage)
        try container.encode(name, forKey: .name)
        try container.encode(locked, forKey: .locked)
    }
}

extension CharacterDisplay {
    func toCharacter() -> Character {
        Character(
            key: self.key,
            isLocked: self.locked
        )
    }
}
