//
//  SplashView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 30.01.26.
//

import SwiftUI

struct SplashView: View {

    @State private var logoScale: CGFloat = 0.88
    @State private var logoOpacity: CGFloat = 0
    @State private var lightOpacity: CGFloat = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {

            // 🌑 Base Background
            Color.black
                .ignoresSafeArea()

            // 🔥 Vertical Signature Light
            LinearGradient(
                colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.06),
                    Color.white.opacity(0.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 120)
            .opacity(lightOpacity)
            .blur(radius: 40)

            // 🌘 Ambient Vignette
            RadialGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.95),
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()

            // 🌀 Logo
            Image("taenttra_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .shadow(
                    color: Color.white.opacity(0.15),
                    radius: 30
                )
                .offset(y: -10)
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {

        // Logo fade + emerge
        withAnimation(.easeOut(duration: 0.7)) {
            logoOpacity = 1
            logoScale = 1.02
        }

        // Signature light reveal
        withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
            lightOpacity = 1
        }

        // Settle
        withAnimation(.easeInOut(duration: 0.4).delay(0.7)) {
            logoScale = 1.0
        }

        // Subtle breathing pulse
        withAnimation(
            .easeInOut(duration: 2.2)
                .repeatForever(autoreverses: true)
                .delay(1.0)
        ) {
            logoScale = 1.01
        }
    }
}
