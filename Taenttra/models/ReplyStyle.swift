//
//  ReplyStyle.swift
//  Taenttara
//

import Foundation

struct ReplyStyle: Identifiable, Decodable {
    let id: String
    let name: String
    let icon: String
    let prompt: String
}

extension Bundle {

    func loadReplyStyles() -> [ReplyStyle] {
        guard
            let url = self.url(
                forResource: "reply_styles",
                withExtension: "json"
            )
        else {
            print("❌ reply_styles.json not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([ReplyStyle].self, from: data)
        } catch {
            print("❌ Failed to load reply styles:", error)
            return []
        }
    }
}
