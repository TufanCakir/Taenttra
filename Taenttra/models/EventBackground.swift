//
//  EventBackground.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Foundation

enum EventBackground: Codable {
    case grid(color: String)
    case image(name: String)

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum BackgroundType: String, Codable {
        case grid
        case image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BackgroundType.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)

        switch type {
        case .grid:
            self = .grid(color: value)
        case .image:
            self = .image(name: value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .grid(let color):
            try container.encode(BackgroundType.grid, forKey: .type)
            try container.encode(color, forKey: .value)

        case .image(let name):
            try container.encode(BackgroundType.image, forKey: .type)
            try container.encode(name, forKey: .value)
        }
    }
}
