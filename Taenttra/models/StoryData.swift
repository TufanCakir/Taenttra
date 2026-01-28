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
    let odrTags: [String]?
    let introDialog: StoryDialog?
    let sections: [StorySection]

    private enum CodingKeys: String, CodingKey {
        case id, title, background, music, introDialog, sections
        case odrTags = "odr_tags"
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
    let odrTags: [String]?
    let introDialog: StoryDialog?

    private enum CodingKeys: String, CodingKey {
        case id, title, enemy, waves, boss, timeLimit, music, introDialog
        case odrTags = "odr_tags"
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

enum StoryLoader {

    static func load() async -> StoryData? {
        let url = URL(
            string:
                "https://raw.githubusercontent.com/TufanCakir/Taenttra/main/Taenttra/ressource/story.json?ts=\(Date().timeIntervalSince1970)"
        )!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(StoryData.self, from: data)
        } catch {
            print("❌ Story load failed:", error)
            return nil
        }
    }
}
