//
//  SplashView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct SplashView: View {

    @State private var logoScale: CGFloat = 0.88
    @State private var logoOpacity: CGFloat = 0
    @State private var lightOpacity: CGFloat = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("taenttra_logo")
                .resizable()
                .scaledToFit()
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
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
