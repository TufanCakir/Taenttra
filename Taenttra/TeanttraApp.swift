//
//  TeanttraApp.swift
//  Taenttra
//

import SwiftData
import SwiftUI

@main
struct TaenttraApp: App {

    @StateObject private var gameState = GameState()
    @StateObject private var network = NetworkMonitor.shared

    @State private var showSplash = true

    private let splashDuration: Double = 1.6
    private let transitionDuration: Double = 0.6

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
                    .transition(.opacity)

                } else if showSplash {

                    SplashView()
                        .transition(.opacity)
                        .zIndex(10)

                } else {

                    GameView()
                        .environmentObject(gameState)
                        .transition(.opacity)
                        .zIndex(0)
                }
            }
            .onAppear(perform: startSplashTimer)
            .animation(
                .easeInOut(duration: transitionDuration),
                value: showSplash
            )
        }
        .modelContainer(for: PlayerWallet.self)
    }

    // MARK: - Splash Control
    private func startSplashTimer() {
        guard showSplash else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
            withAnimation {
                showSplash = false
            }
        }
    }
}
