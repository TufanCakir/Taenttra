//
//  ExamplePrompt.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import Foundation

struct ExamplePrompt: Identifiable, Decodable {
    let id: String
    let modes: [String]
    let text: String
}

extension Bundle {

    func loadExamplePrompts(
        language: String = Locale.current.language.languageCode?.identifier
            ?? "en",
        fallback: String = "en"
    ) -> [ExamplePrompt] {

        if let prompts = loadExamplePromptsFile(language) {
            return prompts
        }

        if let fallbackPrompts = loadExamplePromptsFile(fallback) {
            print("⚠️ Using fallback ExamplePrompts:", fallback)
            return fallbackPrompts
        }

        print("❌ Missing ExamplePrompts – returning empty list")
        return []
    }

    private func loadExamplePromptsFile(_ language: String)
        -> [ExamplePrompt]?
    {
        let file = "ExamplePrompts_\(language)"

        guard
            let url = url(forResource: file, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return nil }

        return try? JSONDecoder().decode(
            [ExamplePrompt].self,
            from: data
        )
    }
}
