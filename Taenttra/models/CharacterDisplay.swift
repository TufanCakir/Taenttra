//
//  CharacterDisplay.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Foundation

struct CharacterDisplay: Identifiable, Codable {

    // MARK: - Properties
    var id: UUID?
    let key: String
    let displayImage: String  // z.B. "kenji_front"
    let name: String
    let locked: Bool

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case displayImage
        case name
        case locked
    }

    // MARK: - Init
    init(
        id: UUID? = nil,
        key: String,
        displayImage: String,
        name: String,
        locked: Bool
    ) {
        self.id = id ?? UUID()
        self.key = key
        self.displayImage = displayImage
        self.name = name
        self.locked = locked
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
        self.locked = try container.decode(Bool.self, forKey: .locked)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(displayImage, forKey: .displayImage)
        try container.encode(name, forKey: .name)
        try container.encode(locked, forKey: .locked)
    }
}

extension CharacterDisplay {

    /// Preview-Bild für Grid / Auswahl
    func previewImage(using wallet: PlayerWallet?) -> String {
        SkinLibrary.previewImage(
            for: key,
            shopSkinId: wallet?.equippedSkin
        )
    }

    /// Übergang in Fight-Character
    func toCharacter(using wallet: PlayerWallet?) -> Character {
        Character(
            key: key,
            isLocked: locked,
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
        default: return "base"
        }
    }

    // MARK: - Grid / UI Preview
    static func previewImage(
        for characterKey: String,
        shopSkinId: String?
    ) -> String {

        switch shopSkinId {
        case "kenji_red_skin":
            return "kenji_red_preview"

        case "kenji_shadow_skin":
            return "kenji_shadow_preview"

        default:
            return "kenji_base_preview"  // 🔥 DAS FEHLTE
        }
    }
}
