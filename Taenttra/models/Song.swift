//
//  Song.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import Foundation

struct Song: Codable, Identifiable {
    let id: UUID
    let key: String
    let file: String
    let loop: Bool
    let volume: Float

    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case file
        case loop
        case volume
    }

    init(
        id: UUID = UUID(),
        key: String,
        file: String,
        loop: Bool,
        volume: Float
    ) {
        self.id = id
        self.key = key
        self.file = file
        self.loop = loop
        self.volume = volume
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id =
            try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.key = try container.decode(String.self, forKey: .key)
        self.file = try container.decode(String.self, forKey: .file)
        self.loop = try container.decode(Bool.self, forKey: .loop)
        self.volume = try container.decode(Float.self, forKey: .volume)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(file, forKey: .file)
        try container.encode(loop, forKey: .loop)
        try container.encode(volume, forKey: .volume)
    }
}
