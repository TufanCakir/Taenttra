//
//  ReplyStyle.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import Foundation

struct ReplyStyle: Identifiable, Decodable {
    let id: String
    let name: String
    let icon: String
    let prompt: String
}

extension Bundle {

    func loadReplyStyles(
        language: String = Locale.current.language.languageCode?.identifier
            ?? "en",
        fallback: String = "en"
    ) -> [ReplyStyle] {

        if let styles = loadReplyStylesFile(language) {
            return styles
        }

        if let fallbackStyles = loadReplyStylesFile(fallback) {
            print("⚠️ Using fallback ReplyStyles:", fallback)
            return fallbackStyles
        }

        print("❌ Missing ReplyStyles – returning empty list")
        return []
    }

    private func loadReplyStylesFile(_ language: String) -> [ReplyStyle]? {
        let file = "reply_styles_\(language)"

        guard
            let url = url(forResource: file, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            return nil
        }

        return try? JSONDecoder().decode(
            [ReplyStyle].self,
            from: data
        )
    }
}
