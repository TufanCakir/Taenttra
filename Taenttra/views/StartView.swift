//
//  StartView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct StartView: View {

    @EnvironmentObject var gameState: GameState

    @State private var breathe = false
    @State private var reveal = false
    @State private var flicker = false

    var body: some View {
        ZStack {

            // 🌑 Deep Base
            Color.black.ignoresSafeArea()

            // 🔥 Vertical Energy Spine (Signature)
            LinearGradient(
                colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(reveal ? 0.06 : 0.0),
                    Color.white.opacity(0.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 140)
            .blur(radius: 50)
            .opacity(reveal ? 1 : 0)

            // 🌘 Ambient Vignette
            RadialGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.95),
                ],
                center: .center,
                startRadius: 120,
                endRadius: 500
            )
            .ignoresSafeArea()

            // 🥊 Character
            Image("ten_base_preview")
                .resizable()
                .scaledToFit()
                .frame(height: 520)
                .offset(y: -60)
                .scaleEffect(breathe ? 1.015 : 1.0)
                .shadow(color: .blue, radius: 50)
                .animation(
                    .easeInOut(duration: 3.2)
                        .repeatForever(autoreverses: true),
                    value: breathe
                )

            // 🕯 Ritual Text + Footer
            VStack {
                Spacer()

                VStack(spacing: 6) {
                    Text("ENTER")
                        .font(.system(size: 14, weight: .heavy))
                        .tracking(6)
                        .foregroundColor(.white.opacity(0.55))

                    Text("TAENTTRA")
                        .font(.system(size: 18, weight: .heavy))
                        .tracking(4)
                        .foregroundColor(.white.opacity(flicker ? 0.9 : 0.4))
                }
                .scaleEffect(flicker ? 1.02 : 0.98)
                .animation(
                    .easeInOut(duration: 1.6)
                        .repeatForever(autoreverses: true),
                    value: flicker
                )
                .padding(.bottom, 24)

                // © Footer
                Text("© 2026 Tufan Cakir")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.bottom, 20)
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
