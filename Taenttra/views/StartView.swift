//
//  StartView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct StartView: View {

    @EnvironmentObject var gameState: GameState

    @State private var pulse = false
    @State private var glow = false

    var body: some View {
        ZStack {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // ✨ BACK GLOW
            RadialGradient(
                colors: [
                    Color.cyan.opacity(glow ? 0.25 : 0.12),
                    .clear,
                ],
                center: .center,
                startRadius: 40,
                endRadius: 320
            )
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: true),
                value: glow
            )

            // 🥊 CHARACTER
            Image("kenji_base_preview")
                .resizable()
                .scaledToFit()
                .frame(height: 520)
                .offset(y: -40)
                .shadow(color: .cyan.opacity(0.35), radius: 40)
                .scaleEffect(pulse ? 1.01 : 1.0)
                .animation(
                    .easeInOut(duration: 1.8)
                        .repeatForever(autoreverses: true),
                    value: pulse
                )

            // 🕹️ UI
            VStack(spacing: 12) {
                Spacer()

                Text("PRESS TO START")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(.cyan)
                    .opacity(pulse ? 1 : 0.35)
                    .scaleEffect(pulse ? 1.05 : 0.95)
                    .animation(
                        .easeInOut(duration: 1.1)
                            .repeatForever(autoreverses: true),
                        value: pulse
                    )
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            pulse = true
            glow = true
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.25)) {
                gameState.screen = .home
            }
        }
    }
}

#Preview {
    StartView()
}
