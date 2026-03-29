//
//  CardView.swift
//  Taenttra
//
//  Created by Codex on 12.08.25.
//

import SwiftUI
import UIKit

struct CardView: View {

    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let deckLimit = 6
        static let maxSlots = 5
    }

    private enum CardMode: String, CaseIterable {
        case collection = "COLLECTION"
        case decks = "DECKS"
    }

    @EnvironmentObject private var gameState: GameState
    @State private var mode: CardMode = .collection
    @State private var selectedSlotIndex = 0
    @State private var selectedCardID: String?

    private let catalog = BattleCardLoader.load()

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private var templateMap: [String: BattleCardTemplate] {
        BattleDeckService.templateMap(from: catalog)
    }

    private var ownedTemplates: [BattleCardTemplate] {
        let ids = wallet?.ownedBattleCardIDs ?? BattleDeckService.starterOwnedCardIDs(from: catalog)
        return ids.compactMap { templateMap[$0] }
            .sorted { lhs, rhs in
                if lhs.rarity == rhs.rarity {
                    return lhs.power > rhs.power
                }
                return rarityScore(lhs.rarity) > rarityScore(rhs.rarity)
            }
    }

    private var deckSlots: [BattleDeckSlot] {
        guard let wallet else { return [] }
        return BattleDeckService.decodeSlots(wallet.deckSlotPayloads)
    }

    private var selectedSlot: BattleDeckSlot? {
        guard deckSlots.indices.contains(selectedSlotIndex) else { return nil }
        return deckSlots[selectedSlotIndex]
    }

    private var selectedTemplate: BattleCardTemplate? {
        guard let selectedCardID else { return nil }
        return templateMap[selectedCardID]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VersusHeaderView()
                    heroCard
                    modePicker

                    if mode == .collection {
                        collectionSection
                    } else {
                        deckSection
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            if let wallet {
                if wallet.deckSlotPayloads.isEmpty {
                    wallet.deckSlotPayloads = BattleDeckService.defaultSlotPayloads(from: catalog)
                }
                if wallet.ownedBattleCardIDs.isEmpty {
                    wallet.ownedBattleCardIDs = BattleDeckService.starterOwnedCardIDs(from: catalog)
                }
                selectedSlotIndex = min(wallet.selectedDeckSlotIndex, max(deckSlots.count - 1, 0))
                selectedCardID = ownedTemplates.first?.id
            }
        }
    }

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.04, blue: 0.11),
                Color(red: 0.06, green: 0.01, blue: 0.12),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                chip("CARD LAB", color: .cyan)
                Spacer()
                chip(activeDeckTitle, color: .yellow)
            }

            Text("DECK CONSOLE")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white)

            Text("Build decks, inspect your owned cards and switch the active slot for battle.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            HStack(spacing: 12) {
                statCard(title: "OWNED", value: "\(ownedTemplates.count)", accent: .cyan)
                statCard(title: "SLOTS", value: "\(deckSlots.count)", accent: .pink)
                statCard(title: "ACTIVE", value: "\(selectedSlotIndex + 1)", accent: .yellow)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private var modePicker: some View {
        HStack(spacing: 10) {
            ForEach(CardMode.allCases, id: \.self) { item in
                Button {
                    mode = item
                } label: {
                    Text(item.rawValue)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(mode == item ? Color.black : .white.opacity(0.72))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(mode == item ? Color.cyan : Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("OWNED CARDS")
            cardGrid(selectOnly: true)
            if let selectedTemplate {
                detailCard(for: selectedTemplate)
            }
        }
        .padding(18)
        .background(sectionBackground)
    }

    private var deckSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionLabel("DECK SLOTS")
                Spacer()
                Button {
                    addSlot()
                } label: {
                    Text("NEW SLOT")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.3)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(deckSlots.count >= Layout.maxSlots ? Color.gray : Color.yellow))
                }
                .disabled(deckSlots.count >= Layout.maxSlots)
                .buttonStyle(.plain)
            }

            slotRow

            if let selectedSlot {
                TextField(
                    "Deck Name",
                    text: Binding(
                        get: { selectedSlot.name },
                        set: { updateSlotName($0) }
                    )
                )
                .textInputAutocapitalization(.words)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                activeDeckButton
                selectedDeckCards
                cardGrid(selectOnly: false)
            }
        }
        .padding(18)
        .background(sectionBackground)
    }

    private var slotRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(deckSlots) { slot in
                    Button {
                        selectedSlotIndex = slot.index
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(slot.name.uppercased())
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("\(slot.cardIDs.count)/\(Layout.deckLimit) CARDS")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(1)
                                .foregroundStyle(slot.index == wallet?.selectedDeckSlotIndex ? .yellow : .white.opacity(0.58))
                        }
                        .padding(14)
                        .frame(width: 132, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(selectedSlotIndex == slot.index ? Color.cyan.opacity(0.24) : Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(selectedSlotIndex == slot.index ? Color.cyan.opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var activeDeckButton: some View {
        Button {
            wallet?.selectedDeckSlotIndex = selectedSlotIndex
        } label: {
            HStack {
                Text(wallet?.selectedDeckSlotIndex == selectedSlotIndex ? "ACTIVE BATTLE DECK" : "SET AS ACTIVE")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.black)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.yellow))
        }
        .buttonStyle(.plain)
    }

    private var selectedDeckCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("ACTIVE SLOT")

            if let selectedSlot, !selectedSlot.cardIDs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedSlot.cardIDs, id: \.self) { cardID in
                            if let template = templateMap[cardID] {
                                deckMiniCard(template)
                            }
                        }
                    }
                }
            } else {
                Text("No cards assigned yet. Tap cards below to add them.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.64))
            }
        }
    }

    private func cardGrid(selectOnly: Bool) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(ownedTemplates) { template in
                buttonCard(template, selectOnly: selectOnly)
            }
        }
    }

    private func buttonCard(_ template: BattleCardTemplate, selectOnly: Bool) -> some View {
        let isInSelectedDeck = selectedSlot?.cardIDs.contains(template.id) ?? false

        return Button {
            selectedCardID = template.id
            guard !selectOnly else { return }
            toggleCard(template.id)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                artworkPreview(for: template, height: 84)

                HStack {
                    Text(template.role.displayTitle)
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(rarityColor(template.rarity))
                    Spacer()
                    Text("\(template.energyCost)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }

                Text(template.title.uppercased())
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(template.subtitle.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.64))
                    .lineLimit(2)

                Text(template.skillText.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)

                HStack {
                    Text(template.rarity.displayTitle)
                        .font(.system(size: 9, weight: .black))
                        .tracking(1)
                        .foregroundStyle(rarityColor(template.rarity))
                    Spacer()
                    Text("\(template.power)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isInSelectedDeck && !selectOnly ? Color.cyan.opacity(0.2) : Color.black.opacity(0.34))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke((selectedCardID == template.id ? Color.white : rarityColor(template.rarity)).opacity(0.45), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func deckMiniCard(_ template: BattleCardTemplate) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            artworkPreview(for: template, height: 58)

            Text(template.title.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(template.role.displayTitle)
                .font(.system(size: 9, weight: .black))
                .tracking(1)
                .foregroundStyle(rarityColor(template.rarity))
            Text("\(template.power)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(12)
        .frame(width: 128, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.34))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(rarityColor(template.rarity).opacity(0.34), lineWidth: 1)
                )
        )
    }

    private func detailCard(for template: BattleCardTemplate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("CARD DETAIL")

            artworkPreview(for: template, height: 180)

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(template.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(template.subtitle.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.64))
                }
                Spacer()
                Text("\(template.power)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 10) {
                detailChip(template.role.displayTitle, color: .cyan)
                detailChip(template.rarity.displayTitle, color: rarityColor(template.rarity))
                detailChip("COST \(template.energyCost)", color: .yellow)
            }

            VStack(alignment: .leading, spacing: 8) {
                detailTextBlock(title: "SKILL", text: template.skillText)
                detailTextBlock(title: "ULTIMATE", text: template.ultimateText)
            }
        }
        .padding(18)
        .background(Color.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func addSlot() {
        guard let wallet, wallet.deckSlotPayloads.count < Layout.maxSlots else { return }
        wallet.deckSlotPayloads = BattleDeckService.appendNewSlot(to: wallet.deckSlotPayloads)
        selectedSlotIndex = wallet.deckSlotPayloads.count - 1
    }

    private func updateSlotName(_ name: String) {
        guard let wallet else { return }
        var slots = deckSlots
        guard slots.indices.contains(selectedSlotIndex) else { return }
        slots[selectedSlotIndex].name = name.isEmpty ? "Deck \(selectedSlotIndex + 1)" : name
        wallet.deckSlotPayloads = BattleDeckService.encodeSlots(slots)
    }

    private func toggleCard(_ cardID: String) {
        guard let wallet else { return }
        var slots = deckSlots
        guard slots.indices.contains(selectedSlotIndex) else { return }

        if let existingIndex = slots[selectedSlotIndex].cardIDs.firstIndex(of: cardID) {
            slots[selectedSlotIndex].cardIDs.remove(at: existingIndex)
        } else if slots[selectedSlotIndex].cardIDs.count < Layout.deckLimit {
            slots[selectedSlotIndex].cardIDs.append(cardID)
        }

        wallet.deckSlotPayloads = BattleDeckService.encodeSlots(slots)
    }

    private var activeDeckTitle: String {
        guard deckSlots.indices.contains(wallet?.selectedDeckSlotIndex ?? 0) else {
            return "NO ACTIVE DECK"
        }
        return deckSlots[wallet?.selectedDeckSlotIndex ?? 0].name.uppercased()
    }

    private func rarityScore(_ rarity: BattleCardRarity) -> Int {
        switch rarity {
        case .common: return 0
        case .rare: return 1
        case .epic: return 2
        case .legendary: return 3
        }
    }

    private func rarityColor(_ rarity: BattleCardRarity) -> Color {
        switch rarity {
        case .common: return .white.opacity(0.72)
        case .rare: return .cyan
        case .epic: return .purple
        case .legendary: return .yellow
        }
    }

    private func chip(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.3)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func statCard(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.62))
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .tracking(2)
            .foregroundStyle(Color.cyan.opacity(0.92))
    }

    private func detailChip(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black))
            .tracking(1.1)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.06), in: Capsule())
    }

    private func detailTextBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .tracking(1.2)
                .foregroundStyle(.cyan.opacity(0.92))
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
    }

    @ViewBuilder
    private func artworkPreview(for template: BattleCardTemplate, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            rarityColor(template.rarity).opacity(0.22),
                            Color.white.opacity(0.05),
                            Color.black.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let artworkName = template.artworkName, UIImage(named: artworkName) != nil {
                Image(artworkName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: height - 10)
            } else {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: max(28, height * 0.24), weight: .black))
                    .foregroundStyle(rarityColor(template.rarity))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
