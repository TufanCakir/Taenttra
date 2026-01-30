//
//  CharacterDisplay.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Foundation

struct CharacterDisplay: Identifiable, Codable {

    let id: UUID
    let key: String
    let displayImage: String
    let name: String
    let combatSpritePrefix: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case displayImage
        case name
        case combatSpritePrefix
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id)

        self.id = decodedId ?? UUID()
        self.key = try container.decode(String.self, forKey: .key)
        self.displayImage = try container.decode(
            String.self,
            forKey: .displayImage
        )
        self.name = try container.decode(String.self, forKey: .name)
        self.combatSpritePrefix = try container.decodeIfPresent(
            String.self,
            forKey: .combatSpritePrefix
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(displayImage, forKey: .displayImage)
        try container.encode(name, forKey: .name)
    }
}

extension CharacterDisplay {

    /// Preview-Bild für Grid / Auswahl
    func previewImage(using wallet: PlayerWallet?) -> String {
        if key == "kenji",
            let skin = wallet?.equippedSkin
        {
            return SkinLibrary.previewImage(
                for: key,
                shopSkinId: skin
            )
        }
        return displayImage
    }

    /// Übergang in Fight-Character
    func toCharacter(using wallet: PlayerWallet?) -> Character {
        Character(
            key: key,
            combatSpritePrefix: combatSpritePrefix,
            isLocked: false,  // 🔥 IM FIGHT IMMER FALSE
            skinId: SkinLibrary.spriteVariant(
                from: wallet?.equippedSkin
            )
        )
    }
}

enum SkinLibrary {

    // MARK: - Shop → Sprite Variant
    static func spriteVariant(from shopSkinId: String?) -> String {
        switch shopSkinId {
        case "kenji_red_skin": return "red"
        case "kenji_shadow_skin": return "shadow"
        case "kenji_tournament_skin": return "tournament"  // 🏆 NEU
        default: return "base"
        }
    }

    // MARK: - Grid / UI Preview
    static func previewImage(
        for characterKey: String,
        shopSkinId: String?
    ) -> String {

        guard let shopSkinId else {
            return "\(characterKey)_base_preview"
        }

        switch shopSkinId {
        case "kenji_red_skin":
            return "kenji_red_preview"

        case "kenji_shadow_skin":
            return "kenji_shadow_preview"

        case "kenji_tournament_skin":  // 🏆 FIX
            return "kenji_tournament_preview"  // 🔥 MUSS EXISTIEREN

        default:
            return "\(characterKey)_base_preview"
        }
    }
}
