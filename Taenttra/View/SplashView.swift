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
            backgroundLayer

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(lightOpacity * 0.22))
                        .frame(width: 260, height: 260)
                        .blur(radius: 26)

                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 2)
                        .frame(width: 222, height: 222)

                    Circle()
                        .stroke(Color.cyan.opacity(0.42), lineWidth: 1)
                        .frame(width: 246, height: 246)

                    Image("taenttra_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 196)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 8) {
                    Text("TAENTTRA")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .opacity(logoOpacity)

                    Text("ARENA SYSTEM ONLINE")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(2.4)
                        .foregroundStyle(.cyan.opacity(0.9))
                        .opacity(lightOpacity)
                }
            }
            .offset(y: -10)
        }
        .onAppear {
            animateIn()
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.01, blue: 0.16),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.15))
                .frame(width: 320, height: 320)
                .blur(radius: 46)
                .offset(x: -110, y: -220)

            Circle()
                .fill(Color.pink.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 48)
                .offset(x: 120, y: 180)
        }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.7)) {
            logoOpacity = 1
            logoScale = 1.02
        }

        withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
            lightOpacity = 1
        }

        withAnimation(.easeInOut(duration: 0.4).delay(0.7)) {
            logoScale = 1.0
        }

        withAnimation(
            .easeInOut(duration: 2.2)
                .repeatForever(autoreverses: true)
                .delay(1.0)
        ) {
            logoScale = 1.01
            pulse = true
        }
    }
}
