//
//  NewsItem.swift
//  Taenttra
//
//  Created by Tufan Cakir on 06.02.26.
//

import Foundation

enum NewsCategory: String, Codable, CaseIterable {
    case arcade
    case character
    case event
    case shop
    case story
    case survival
    case training

    var title: String {
        rawValue.uppercased()
    }
}

enum NewsImageType: String, Codable {
    case background
    case character
}

struct NewsItem: Identifiable, Codable {
    let id: String
    let category: NewsCategory
    let title: String
    let description: String
    let image: String?
    let imageType: NewsImageType
    let date: Date
}

final class NewsLoader {

    static func load() -> [NewsItem] {
        guard
            let url = Bundle.main.url(
                forResource: "news",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url)
        else {
            print("⚠️ news.json not found")
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return (try? decoder.decode([NewsItem].self, from: data))
            .map { $0.sorted { $0.date > $1.date } } ?? []
    }
}
