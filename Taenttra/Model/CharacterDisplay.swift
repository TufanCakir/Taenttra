//
//  CharacterDisplay.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation
import UIKit

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

    func previewImage(using wallet: PlayerWallet?) -> String {
        guard key == "kenji" else {
            return displayImage
        }

        return SkinLibrary.previewImage(
            for: key,
            skinId: wallet?.equippedSkin
        )
    }
    
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

    private static let baseSkinID = "base"
    private static let legacyKenjiPrefix = "kenji_"

    static func spriteId(from equippedSkinId: String?) -> String {
        normalizedSkinId(equippedSkinId) ?? baseSkinID
    }

    static func normalizedSkinId(_ raw: String?) -> String? {
        guard let raw else { return nil }

        if raw.hasPrefix(legacyKenjiPrefix) {
            return raw.replacingOccurrences(of: legacyKenjiPrefix, with: "")
        }

        return raw
    }

    static func previewImage(
        for characterKey: String,
        skinId rawSkinId: String?
    ) -> String {
        let assetName = AssetName.preview(
            key: characterKey,
            skin: normalizedSkinId(rawSkinId) ?? baseSkinID
        )

        return UIImage(named: assetName) == nil ? fallbackPreview(for: characterKey) : assetName
    }

    private static func fallbackPreview(for characterKey: String) -> String {
        AssetName.preview(
            key: characterKey,
            skin: baseSkinID
        )
    }
}
