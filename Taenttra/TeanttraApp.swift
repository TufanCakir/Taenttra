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

    @State private var showSplash = true

    init() {
        GameCenterManager.shared.authenticate()

        if AudioManager.shared.musicEnabled {
            AudioManager.shared.playMenuMusic()
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea()

                if !network.isConnected {
                    ConnectionRequiredView(
                        message: "Taenttra requires an internet connection."
                    )
                } else if showSplash {
                    SplashView()
                        .transition(
                            .opacity
                                .combined(with: .scale(scale: 1.03))
                        )
                        .blur(radius: showSplash ? 12 : 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 1.6
                            ) {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    GameView()
                        .environmentObject(gameState)
                        .transition(
                            .opacity
                                .combined(with: .scale(scale: 1.05))
                        )
                }
            }
            .animation(.easeOut(duration: 0.45), value: showSplash)
        }
        .modelContainer(for: PlayerWallet.self)
    }
}
