//
//  TeanttraApp.swift
//  Taenttra
//

import SwiftData
import SwiftUI

@main
struct TeanttraApp: App {
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var crystalManager = CrystalManager.shared

    @StateObject private var gameState = GameState()
    @StateObject private var network = NetworkMonitor.shared

    init() {
        GameCenterManager.shared.authenticate()
    }

    var body: some Scene {
        WindowGroup {
            Group {

                // ❌ Kein Internet → blockieren
                if !network.isConnected {
                    ConnectionRequiredView(
                        message:
                            "Taenttra requires an internet connection."
                    )
                }

                // ✅ Internet da → Spiel starten
                else {
                    GameView()
                        .environmentObject(gameState)
                }
            }
        }
        .modelContainer(for: PlayerWallet.self)
    }
}
