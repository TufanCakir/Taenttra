//
//  StartView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct StartView: View {

    @EnvironmentObject var gameState: GameState

    @State private var breathe = false
    @State private var reveal = false
    @State private var flicker = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("char_kenji_base_preview")
                .resizable()
                .scaledToFit()
                .scaleEffect(breathe ? 1.015 : 1.0)
                .shadow(color: .blue, radius: 50)
                .animation(
                    .easeInOut(duration: 3.2)
                        .repeatForever(autoreverses: true),
                    value: breathe
                )

            VStack {
                Spacer()

                VStack(spacing: 16) {

                    Text("Taenttra")
                        .foregroundColor(.white.opacity(flicker ? 0.9 : 0.4))
                }
                .scaleEffect(flicker ? 1.02 : 0.98)
                .animation(
                    .easeInOut(duration: 1.6)
                        .repeatForever(autoreverses: true),
                    value: flicker
                )
                .padding()

                Text("© 2026 Tufan Cakir")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            reveal = true
            breathe = true
            flicker = true
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.28)) {
                gameState.screen = .home
            }
        }
    }
}

#Preview {
    StartView()
        .environmentObject(GameState())
}
