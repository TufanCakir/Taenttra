//
//  TeanttraApp.swift
//  Taenttra
//

import SwiftData
import SwiftUI

@main
struct TeanttraApp: App {

    @StateObject private var gameState = GameState()
    @StateObject private var network = NetworkMonitor.shared

    init() {
        GameCenterManager.shared.authenticate()

        if AudioManager.shared.musicEnabled {
            AudioManager.shared.playMenuMusic()
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !network.isConnected {
                    ConnectionRequiredView(
                        message: "Taenttra requires an internet connection."
                    )
                } else {
                    GameView()
                        .environmentObject(gameState)
                }
            }
        }
        // ✅ EINZIGER Container – persistent auf Disk
        .modelContainer(for: PlayerWallet.self)
    }
}
