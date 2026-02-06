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
        try container.encodeIfPresent(
            combatSpritePrefix,
            forKey: .combatSpritePrefix
        )
    }
}

extension CharacterDisplay {

    /// Preview-Bild für Grid / Auswahl
    func previewImage(using wallet: PlayerWallet?) -> String {
        guard key == "ten" else {
            return displayImage
        }

        let skinId = wallet?.equippedSkin
        return SkinLibrary.previewImage(
            for: key,
            skinId: skinId
        )
    }
}

extension CharacterDisplay {

    /// Übergang in Fight-Character
    func toCharacter(using wallet: PlayerWallet?) -> Character {
        Character(
            key: key,
            spriteBaseKey: combatSpritePrefix,
            skinId: SkinLibrary.spriteId(
                from: wallet?.equippedSkin
            ),
            isLocked: false
        )
    }
}

enum SkinLibrary {

    // MARK: - Normalize Skin ID
    static func normalizedSkinId(_ raw: String?) -> String? {
        guard let raw else { return nil }

        // Falls alte Daten noch "ten_*" enthalten
        if raw.hasPrefix("ten") {
            return raw.replacingOccurrences(of: "ten_", with: "")
        }

        return raw
    }

    // MARK: - Preview Images (UI)
    static func previewImage(
        for characterKey: String,
        skinId rawSkinId: String?
    ) -> String {

        guard let skinId = normalizedSkinId(rawSkinId) else {
            return "\(characterKey)_base_preview"
        }

        return "\(characterKey)_\(skinId)_preview"
    }

    // MARK: - Sprite-ID für Fight
    static func spriteId(from equippedSkinId: String?) -> String {
        normalizedSkinId(equippedSkinId) ?? "base"
    }
}
