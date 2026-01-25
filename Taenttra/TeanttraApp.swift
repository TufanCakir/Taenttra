//
//  TeanttraApp.swift
//  Taenttra
//

import SwiftData
import SwiftUI

@main
struct TeanttraApp: App {

    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(gameState)
        }
        .modelContainer(for: PlayerWallet.self)
    }
}
