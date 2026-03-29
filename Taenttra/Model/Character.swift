//
//  Character.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation
import UIKit

struct Character: Identifiable {

    let id = UUID()
    let key: String
    let spriteBaseKey: String
    let skinId: String?
    let isLocked: Bool

    init(
        key: String,
        spriteBaseKey: String? = nil,
        skinId: String?,
        isLocked: Bool = false
    ) {
        self.key = key
        self.spriteBaseKey = spriteBaseKey ?? key
        self.skinId = skinId
        self.isLocked = isLocked
    }

    func spriteName(for state: CharacterState) -> String {
        SpriteResolver.resolve(
            baseKey: spriteBaseKey,
            skinId: skinId,
            state: state
        )
    }
}

enum SpriteResolver {
    static func resolve(
        baseKey: String,
        skinId: String?,
        state: CharacterState
    ) -> String {

        let skin = skinId ?? "base"

        let candidates: [String] = [
            AssetName.character(
                key: baseKey,
                skin: skin,
                state: state.rawValue
            ),

            AssetName.character(
                key: baseKey,
                skin: "base",
                state: state.rawValue
            ),

            AssetName.character(
                key: baseKey,
                skin: "base",
                state: "idle"
            ),

            AssetName.character(
                key: "kenji",
                skin: "base",
                state: "idle"
            )
        ]

        for name in candidates {
            if UIImage(named: name) != nil {
                return name
            }
        }

        return "char_kenji_base_idle"
    }
}

enum CharacterState: String, CaseIterable {
    case idle
    case punch
    case kick
}

enum CharacterFactory {

    static func player(
        key: String,
        skinId: String?
    ) -> Character {
        Character(
            key: key,
            skinId: skinId
        )
    }

    static func enemy(
        key: String,
        skinId: String? = nil
    ) -> Character {
        Character(
            key: key,
            skinId: skinId
        )
    }

    static func mentor(
        key: String,
        usesSpritesOf baseKey: String
    ) -> Character {
        Character(
            key: key,
            spriteBaseKey: baseKey,
            skinId: nil
        )
    }
}

extension Character {

    static func player(
        key: String,
        skinId: String?
    ) -> Character {
        CharacterFactory.player(
            key: key,
            skinId: skinId
        )
    }

    static func enemy(
        key: String,
        skinId: String? = nil
    ) -> Character {
        CharacterFactory.enemy(
            key: key,
            skinId: skinId
        )
    }
}
