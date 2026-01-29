//
//  StoryData.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation

struct StoryData: Decodable {
    let chapters: [StoryChapter]
}

struct StoryChapter: Decodable, Identifiable {
    let id: String
    let title: String
    let background: String
    let music: String
    let introDialog: StoryDialog?
    let sections: [StorySection]

    private enum CodingKeys: String, CodingKey {
        case id, title, background, music, introDialog, sections
    }
}

struct StorySection: Decodable, Identifiable {
    let id: String
    let title: String
    let enemies: [String]
    let waves: Int
    let boss: Bool?
    let timeLimit: Int
    let music: String?
    let arena: String
    let unlocks: [String]?
    let introDialog: StoryDialog?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case enemy  // JSON may use singular "enemy"
        case enemies  // support plural if present
        case waves
        case boss
        case timeLimit
        case music
        case arena
        case unlocks
        case introDialog
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)

        // Decode enemies: support either `enemies: [String]` or `enemy: String`/`enemy: [String]`
        if let arr = try? container.decode([String].self, forKey: .enemies) {
            enemies = arr
        } else if let arr = try? container.decode([String].self, forKey: .enemy)
        {
            enemies = arr
        } else if let single = try? container.decode(
            String.self,
            forKey: .enemy
        ) {
            enemies = [single]
        } else {
            enemies = []
        }

        waves = try container.decode(Int.self, forKey: .waves)
        boss = try container.decodeIfPresent(Bool.self, forKey: .boss)
        timeLimit = try container.decode(Int.self, forKey: .timeLimit)
        music = try container.decodeIfPresent(String.self, forKey: .music)
        arena = try container.decode(String.self, forKey: .arena)
        unlocks = try container.decodeIfPresent([String].self, forKey: .unlocks)
        introDialog = try container.decodeIfPresent(
            StoryDialog.self,
            forKey: .introDialog
        )
    }
}

struct StoryDialog: Decodable, Identifiable, Hashable {
    let id = UUID()
    let image: String
    let text: String

    private enum CodingKeys: String, CodingKey {
        case image
        case text
    }
}

final class StoryLoader {

    static func load() -> StoryData {
        guard
            let url = Bundle.main.url(
                forResource: "story",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let story = try? JSONDecoder().decode(StoryData.self, from: data)
        else {
            fatalError("story.json fehlt oder kaputt")
        }

        return story
    }
}
