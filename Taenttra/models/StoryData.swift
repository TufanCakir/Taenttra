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
    let sections: [StorySection]
}

struct StorySection: Decodable, Identifiable {
    let id: String
    let enemy: String
    let waves: Int
    let boss: Bool?
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
