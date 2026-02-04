//
//  KOView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 04.02.26.
//

import SwiftUI

struct KOView: View {

    let winnerSide: FighterSide
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.4
    @State private var opacity: CGFloat = 0
    @State private var flash = false
    @State private var showContinue = false
    @State private var shake: CGFloat = 0

    var body: some View {
        ZStack {

            // 🌑 DARK BACKDROP + VIGNETTE
            Color.black
                .opacity(0.75)
                .ignoresSafeArea()
                .overlay(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.9),
                        ],
                        center: .center,
                        startRadius: 120,
                        endRadius: 420
                    )
                )

            VStack(spacing: 20) {

                Text("PRESS ANY BUTTON")
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .opacity(0.5)

                // 💥 KO
                Text("K.O.")
                    .font(.system(size: 104, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.red.opacity(0.9), lineWidth: 3)
                            .mask(
                                Text("K.O.")
                                    .font(.system(size: 104, weight: .black))
                            )
                    )
                    .shadow(color: .red.opacity(0.9), radius: 12)  // statt 20+
                    .offset(x: shake)

                // 🏆 RESULT
                Text(winnerText)
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(3)
                    .foregroundColor(winnerColor)
                    .shadow(color: winnerColor.opacity(0.9), radius: 14)
            }
            .scaleEffect(scale)
            .opacity(opacity)

            // ▶️ CONTINUE
            if showContinue {
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .heavy))
                        .tracking(3.5)
                        .shadow(color: .red.opacity(0.8), radius: 10)
                        .scaleEffect(showContinue ? 1.0 : 0.95)
                        .animation(
                            .easeInOut(duration: 0.9).repeatForever(
                                autoreverses: true
                            ),
                            value: showContinue
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal, 54)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(0.9),
                                    Color.red.opacity(0.6),
                                    Color.black.opacity(0.6),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(winnerColor.opacity(0.9), lineWidth: 2)
                        )
                        .cornerRadius(16)
                        .shadow(color: winnerColor.opacity(0.9), radius: 18)
                }
                .padding(.top, 350)
                .transition(.scale.combined(with: .opacity))
            }
        }
        // ⚡️ FLASH
        .background(
            flash ? Color.red.opacity(0.6) : Color.clear
        )
        .onAppear {
            playAnimation()
        }
    }

    // MARK: - Computed

    private var winnerText: String {
        winnerSide == .left ? "PLAYER WINS" : "ENEMY WINS"
    }

    private var winnerColor: Color {
        winnerSide == .left ? .cyan : .red
    }

    // MARK: - Animation

    private func playAnimation() {

        // 💥 HIT FLASH
        flash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            flash = false
        }

        // 📈 SLAM IN
        withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
            scale = 1
            opacity = 1
        }

        // ⚡️ SHAKE
        withAnimation(
            .easeInOut(duration: 0.06).repeatCount(4, autoreverses: true)
        ) {
            shake = 10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            shake = 0
        }

        // ▶️ CONTINUE DELAY
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showContinue = true
            }
        }
    }
}
