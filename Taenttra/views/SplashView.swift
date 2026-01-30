//
//  SplashView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 30.01.26.
//

import SwiftUI

struct SplashView: View {

    @State private var scale: CGFloat = 0.92
    @State private var opacity: CGFloat = 0
    @State private var glowOpacity: CGFloat = 0

    var body: some View {
        ZStack {

            // 🌑 Background
            Color.black
                .ignoresSafeArea()

            // 🌘 Subtile Vignette
            RadialGradient(
                colors: [
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.9),
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()

            // 🌀 Logo
            Image("taenttra_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .scaleEffect(scale)
                .opacity(opacity)
                .shadow(
                    color: Color.cyan.opacity(glowOpacity),
                    radius: 40
                )
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {

        // Fade + Scale In
        withAnimation(.easeOut(duration: 0.6)) {
            opacity = 1
            scale = 1.02
        }

        // Glow
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            glowOpacity = 0.8
        }

        // Settle to final size
        withAnimation(.easeInOut(duration: 0.4).delay(0.6)) {
            scale = 1.0
        }
    }
}
