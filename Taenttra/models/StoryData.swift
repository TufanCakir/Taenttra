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
        let base = "https://raw.githubusercontent.com/TufanCakir/Taenttra/main/Taenttra/ressource/story.json"

        var comps = URLComponents(string: base)!
        comps.queryItems = [
            URLQueryItem(name: "v", value: String(Int(Date().timeIntervalSince1970)))
        ]

        var request = URLRequest(url: comps.url!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                print("🌐 story.json status:", http.statusCode)
            }
            print("📦 story.json bytes:", data.count)

            return try JSONDecoder().decode(StoryData.self, from: data)
        } catch {
            print("❌ Story load failed:", error)
            return nil
        }
    }
}
