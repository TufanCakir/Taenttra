//
//  CrystalManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import Combine
import SwiftUI

final class CrystalManager: ObservableObject {

    static let shared = CrystalManager()

    @Published private(set) var crystals: Int = 0

    private let storageKey = "crystals_storage"

    private init() {
        crystals = UserDefaults.standard.integer(forKey: storageKey)
    }

    func add(_ amount: Int) {
        guard amount > 0 else { return }
        crystals += amount
        save()
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, crystals >= amount else { return false }
        crystals -= amount
        save()
        return true
    }

    func reset() {
        crystals = 0
        save()
    }

    private func save() {
        UserDefaults.standard.set(crystals, forKey: storageKey)
    }
}
