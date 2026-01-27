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
    let combatSpritePrefix: String?
    let isLocked: Bool
    let skinId: String?

    // 🔥 EINZIGE combatKey-Quelle
    private var combatKey: String {
        combatSpritePrefix ?? key
    }

    func imageNameSafe(for state: CharacterState) -> String {

        // 1️⃣ Skin + State
        if let skinId {
            let skinned = "char_\(combatKey)_\(skinId)_\(state.rawValue)"
            if UIImage(named: skinned) != nil {
                return skinned
            }
        }

        // 2️⃣ Base + State
        let baseState = "char_\(combatKey)_base_\(state.rawValue)"
        if UIImage(named: baseState) != nil {
            return baseState
        }

        // 3️⃣ Base Idle
        let baseIdle = "char_\(combatKey)_base_idle"
        if UIImage(named: baseIdle) != nil {
            return baseIdle
        }

        // 4️⃣ Global fallback
        print("⚠️ Missing sprite for \(combatKey)")
        return "char_fallback"
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

func loadCharactersFromAssets(
    equippedSkin: String?
) -> [Character] {

    [
        Character(
            key: "kenji",
            combatSpritePrefix: nil,
            isLocked: false,
            skinId: equippedSkin
        ),
        Character(
            key: "ren_dao",
            combatSpritePrefix: "kenji",  // 🔥 nutzt Kenji-Sprites
            isLocked: false,
            skinId: nil  // Mentor hat keine Skins
        ),
    ]
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

extension Character {

    static func enemy(
        key: String,
        skinId: String?
    ) -> Character {
        Character(
            key: key,
            combatSpritePrefix: nil,  // ⛔️ kein Sprite-Fallback
            isLocked: false,
            skinId: skinId
        )
    }
}
