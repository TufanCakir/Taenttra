//
//  TaenttraApp.swift
//  Taenttra
//

import SwiftUI
import SwiftData

@main
struct TaenttraApp: App {

    @State private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
