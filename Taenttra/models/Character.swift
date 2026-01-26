//
//  Character.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import Foundation
import UIKit

struct Character: Identifiable {
    let id = UUID()
    let key: String
    let isLocked: Bool
    let skinId: String  // "base" | "red" | "shadow"

    func imageNameSafe(for state: CharacterState) -> String {
        let name = "char_\(key)_\(skinId)_\(state.rawValue)"
        if UIImage(named: name) != nil {
            return name
        }

        let idle = "char_\(key)_\(skinId)_idle"
        if UIImage(named: idle) != nil {
            return idle
        }

        fatalError("❌ Missing sprite: \(name)")
    }
}

enum CharacterState: String, CaseIterable {
    case idle
    case punch
    case kick
}

enum PlayerSide {
    case left
    case right
}

struct CharacterData: Codable {
    let id: String
    let image: String
    let style: String
}

func loadCharactersFromAssets() -> [Character] {

    let characterKeys = ["kenji"]
    let unlockedCount = 2

    return characterKeys.enumerated().map { index, key in
        Character(
            key: key,
            isLocked: index >= unlockedCount,
            skinId: "base"  // 🔥 Default Skin
        )
    }
}

func loadCharacterDisplays() -> [CharacterDisplay] {
    guard
        let url = Bundle.main.url(
            forResource: "characters",
            withExtension: "json"
        ),
        let data = try? Data(contentsOf: url),
        let decoded = try? JSONDecoder().decode(
            [CharacterDisplay].self,
            from: data
        )
    else {
        return []
    }

    return decoded
}
