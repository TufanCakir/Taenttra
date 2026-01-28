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
    let enemy: String
    let waves: Int
    let boss: Bool?
    let timeLimit: Int
    let music: String?
    let introDialog: StoryDialog?

    private enum CodingKeys: String, CodingKey {
        case id, title, enemy, waves, boss, timeLimit, music, introDialog
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
