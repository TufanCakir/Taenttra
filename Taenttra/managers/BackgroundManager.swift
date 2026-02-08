//
//  BackgroundManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import Combine
import Foundation

@MainActor
final class BackgroundManager: ObservableObject {

    static let shared = BackgroundManager()

    @Published var owned: Set<BackgroundStyle> = [.blueGrid]
    @Published var selected: BackgroundStyle = .blueGrid

    private let ownedKey = "ownedBackgrounds"
    private let selectedKey = "selectedBackground"

    private init() {
        load()
    }

    // ✅ NEU: Check ob freigeschaltet
    func isUnlocked(_ style: BackgroundStyle) -> Bool {
        owned.contains(style)
    }

    func unlock(_ style: BackgroundStyle) {
        owned.insert(style)
        save()
    }

    func select(_ style: BackgroundStyle) {
        guard owned.contains(style) else { return }
        selected = style
        save()
    }

    private func save() {
        UserDefaults.standard.set(
            owned.map(\.rawValue),
            forKey: ownedKey
        )
        UserDefaults.standard.set(
            selected.rawValue,
            forKey: selectedKey
        )
    }

    private func load() {
        if let raw = UserDefaults.standard.stringArray(forKey: ownedKey) {
            owned = Set(raw.compactMap(BackgroundStyle.init))
        }
        if let sel = UserDefaults.standard.string(forKey: selectedKey),
            let style = BackgroundStyle(rawValue: sel)
        {
            selected = style
        }
    }
}
