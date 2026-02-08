//
//  Greeting.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import Foundation

struct Greeting: Identifiable, Decodable {
    let id: String
    let text: String
    let sfSymbol: String?
    let fromHour: Int?
    let toHour: Int?

    func isValidNow() -> Bool {
        guard let from = fromHour, let to = toHour else { return true }

        let hour = Calendar.current.component(.hour, from: Date())

        // Normaler Bereich (z.B. 5–11)
        if from <= to {
            return (from...to).contains(hour)
        }

        // Über-Mitternacht-Bereich (z.B. 22–4)
        return hour >= from || hour <= to
    }

    static func fallback() -> Greeting {
        Greeting(
            id: "fallback",
            text: "Welcome to Taenttra",
            sfSymbol: "sparkles",
            fromHour: nil,
            toHour: nil
        )
    }
}

extension Bundle {

    func loadGreetings(
        language: String = Locale.current.language.languageCode?.identifier
            ?? "en",
        fallback: String = "en"
    ) -> [Greeting] {

        if let greetings = loadGreetingsFile(language) {
            return greetings
        }

        if let fallbackGreetings = loadGreetingsFile(fallback) {
            print("⚠️ Using fallback Greetings:", fallback)
            return fallbackGreetings
        }

        print("❌ Missing Greetings – using hard fallback")
        return [Greeting.fallback()]
    }

    private func loadGreetingsFile(_ language: String) -> [Greeting]? {
        let file = "greetings_\(language)"

        guard
            let url = url(forResource: file, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            return nil
        }

        return try? JSONDecoder().decode(
            [Greeting].self,
            from: data
        )
    }
}
