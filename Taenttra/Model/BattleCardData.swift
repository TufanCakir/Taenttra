//
//  BattleCardData.swift
//  Taenttra
//
//  Created by Codex on 12.08.25.
//

import Foundation

enum BattleCardRarity: String, Codable, CaseIterable {
    case common
    case rare
    case epic
    case legendary

    var displayTitle: String {
        rawValue.uppercased()
    }
}

enum BattleCardRole: String, Codable, CaseIterable {
    case attacker
    case booster
    case guardUnit

    var displayTitle: String {
        switch self {
        case .attacker:
            return "ATTACKER"
        case .booster:
            return "BOOSTER"
        case .guardUnit:
            return "GUARD"
        }
    }
}

struct BattleCardTemplate: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let role: BattleCardRole
    let rarity: BattleCardRarity
    let power: Int
    let energyCost: Int
    let artworkName: String?
    let skillText: String
    let ultimateText: String
}

struct BattleCardCharacterCatalog: Codable {
    let key: String
    let cards: [BattleCardTemplate]
}

struct BattleCardCatalog: Codable {
    let defaults: [BattleCardTemplate]
    let characters: [BattleCardCharacterCatalog]
}

struct BattleDeckSlot: Identifiable, Equatable {
    let id: UUID
    let index: Int
    var name: String
    var cardIDs: [String]
}

enum BattleCardLoader {
    static func load() -> BattleCardCatalog {
        guard
            let url = Bundle.main.url(forResource: "battle_cards", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let catalog = try? JSONDecoder().decode(BattleCardCatalog.self, from: data)
        else {
            return BattleCardCatalog(defaults: [], characters: [])
        }

        return catalog
    }
}

enum BattleDeckService {
    private static let slotSeparator = "|"
    private static let cardSeparator = ","

    static func starterOwnedCardIDs(from catalog: BattleCardCatalog) -> [String] {
        var ids = catalog.defaults.map(\.id)

        if let kenji = catalog.characters.first(where: { $0.key == "kenji" }) {
            ids.append(contentsOf: kenji.cards.map(\.id))
        }

        return Array(Set(ids)).sorted()
    }

    static func defaultSlotPayloads(from catalog: BattleCardCatalog) -> [String] {
        let starterCards: [String]
        if let kenji = catalog.characters.first(where: { $0.key == "kenji" }), !kenji.cards.isEmpty {
            starterCards = Array(kenji.cards.prefix(3).map(\.id))
        } else {
            starterCards = Array(catalog.defaults.prefix(3).map(\.id))
        }

        return [
            encodeSlot(name: "Starter Deck", cardIDs: starterCards)
        ]
    }

    static func decodeSlots(_ payloads: [String]) -> [BattleDeckSlot] {
        payloads.enumerated().map { index, payload in
            let parts = payload.components(separatedBy: slotSeparator)
            let name = parts.first?.isEmpty == false ? parts[0] : "Deck \(index + 1)"
            let cards = parts.count > 1
                ? parts[1].split(separator: ",").map(String.init)
                : []

            return BattleDeckSlot(
                id: UUID(),
                index: index,
                name: name,
                cardIDs: cards
            )
        }
    }

    static func encodeSlots(_ slots: [BattleDeckSlot]) -> [String] {
        slots.map { encodeSlot(name: $0.name, cardIDs: $0.cardIDs) }
    }

    static func appendNewSlot(to payloads: [String]) -> [String] {
        var updated = payloads
        updated.append(encodeSlot(name: "Deck \(payloads.count + 1)", cardIDs: []))
        return updated
    }

    static func templateMap(from catalog: BattleCardCatalog) -> [String: BattleCardTemplate] {
        let all = catalog.defaults + catalog.characters.flatMap(\.cards)
        return Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }

    static func templates(for key: String?, in catalog: BattleCardCatalog) -> [BattleCardTemplate] {
        if
            let key,
            let characterSet = catalog.characters.first(where: { $0.key.caseInsensitiveCompare(key) == .orderedSame }),
            !characterSet.cards.isEmpty
        {
            return characterSet.cards
        }

        return catalog.defaults
    }

    static func resolvePlayerTemplates(
        wallet: PlayerWallet?,
        selectedCharacterKey: String?,
        in catalog: BattleCardCatalog
    ) -> [BattleCardTemplate] {
        let templateByID = templateMap(from: catalog)

        if
            let wallet,
            wallet.deckSlotPayloads.indices.contains(wallet.selectedDeckSlotIndex)
        {
            let slots = decodeSlots(wallet.deckSlotPayloads)
            let selectedSlot = slots[wallet.selectedDeckSlotIndex]
            let resolved = selectedSlot.cardIDs.compactMap { templateByID[$0] }
            if !resolved.isEmpty {
                return resolved
            }
        }

        return templates(for: selectedCharacterKey, in: catalog)
    }

    private static func encodeSlot(name: String, cardIDs: [String]) -> String {
        "\(name)\(slotSeparator)\(cardIDs.joined(separator: cardSeparator))"
    }
}
