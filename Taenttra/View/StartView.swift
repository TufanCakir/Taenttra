//
//  StartView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct StartView: View {
    private enum Layout {
        static let heroOrbSize: CGFloat = 300
        static let heroImageHeight: CGFloat = 320
    }

    @EnvironmentObject var gameState: GameState

    @State private var breathe = false
    @State private var shimmer = false
    @State private var pulseCTA = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                titleBlock

                Spacer(minLength: 10)

                heroDisplay

                Spacer(minLength: 18)

                ctaSection

                Spacer(minLength: 24)

                footer
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .onAppear {
            breathe = true
            shimmer = true
            pulseCTA = true
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.28)) {
                gameState.screen = .home
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.07),
                    Color(red: 0.05, green: 0.01, blue: 0.17),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -120, y: -250)

            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 360, height: 360)
                .blur(radius: 44)
                .offset(x: 130, y: 120)

            AngularGradient(
                colors: [
                    .clear,
                    .white.opacity(0.08),
                    .clear,
                    .cyan.opacity(0.14),
                    .clear,
                    .pink.opacity(0.18),
                    .clear,
                ],
                center: .center
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 12) {
            Text("TAENTTRA")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .tracking(3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan.opacity(0.9), .pink.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.4), radius: 14)
                .scaleEffect(shimmer ? 1.01 : 0.99)
                .animation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: shimmer
                )

            Text("RIVAL SPIRITS • CLASH MODE • ONLINE BATTLE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2.4)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var heroDisplay: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.34),
                            Color.pink.opacity(0.2),
                            Color.black.opacity(0.94),
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 170
                    )
                )
                .frame(width: Layout.heroOrbSize, height: Layout.heroOrbSize)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 8)
                )
                .overlay(
                    Circle()
                        .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                        .padding(12)
                )
                .shadow(color: .cyan.opacity(0.4), radius: 22)

            Image("char_kenji_base_preview")
                .resizable()
                .scaledToFit()
                .frame(height: Layout.heroImageHeight)
                .scaleEffect(breathe ? 1.03 : 0.99)
                .shadow(color: .white.opacity(0.12), radius: 8)
                .shadow(color: .cyan.opacity(0.35), radius: 26)
                .offset(y: -4)
                .animation(
                    .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                    value: breathe
                )

            VStack {
                HStack {
                    chip(title: "RANK", value: "B")
                    Spacer()
                    chip(title: "TYPE", value: "STRIKER")
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                Spacer()

                Text("KENJI")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.white)
                    .padding(.bottom, 24)
            }
            .frame(width: Layout.heroOrbSize, height: Layout.heroOrbSize)
        }
    }

    private var ctaSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color.cyan.opacity(0.92),
                                Color.pink.opacity(0.88),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 78)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.45), lineWidth: 3)
                    )
                    .shadow(color: .cyan.opacity(0.38), radius: 16)
                    .scaleEffect(pulseCTA ? 1.02 : 0.98)
                    .animation(
                        .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                        value: pulseCTA
                    )

                VStack(spacing: 4) {
                    Text("TAP TO ENTER")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.black.opacity(0.88))

                    Text("OPEN THE BATTLE LOBBY")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.black.opacity(0.62))
                }
            }

            Text("Build your fighter, unlock modes, and jump into the arena.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.cyan)
                    .frame(width: 7, height: 7)
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 7, height: 7)
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 7, height: 7)
            }

            Text("© 2026 Tufan Cakir")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
        }
    }

    private func chip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.6))

            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.5))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

#Preview {
    StartView()
        .environmentObject(GameState())
}
