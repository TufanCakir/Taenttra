//
//  WelcomeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct WelcomeView: View {

    @State private var showText = false
    @State private var zoom: CGFloat = 1.08
    @State private var navigate = false
    @StateObject private var pulse = PulseManager()

    var body: some View {
        NavigationStack {
            ZStack {

                // 🔥 SPLASH BACKGROUND
                Image("splash_icon")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(zoom)
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(.easeOut(duration: 2.8)) {
                            zoom = 1.0
                        }
                    }

                // 🌑 CINEMATIC OVERLAY
                LinearGradient(
                    colors: [
                        .black.opacity(0.45),
                        .black.opacity(0.15),
                        .black.opacity(0.35),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                GeometryReader { proxy in
                    let size = proxy.size
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)

                    ZStack {
                        VStack {
                            Spacer(minLength: 120)

                            // 🐉 TITLE
                            Text("Willkommen zu Taenttra")
                                .font(
                                    .system(
                                        size: 30,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(showText ? 1 : 0)
                                .offset(y: showText ? 0 : 18)
                                .scaleEffect(showText ? 1 : 0.96)
                                .animation(
                                    .easeOut(duration: 1.4),
                                    value: showText
                                )
                                .shadow(color: .black, radius: 10)

                            Spacer()

                            // 👆 TAP HINT
                            Text("Tippe zum Starten")
                                .font(
                                    .system(
                                        size: 30,
                                        weight: .medium,
                                        design: .rounded
                                    )
                                )
                                .foregroundColor(.white)
                                .opacity(showText ? 1 : 0)
                                .padding(.bottom, 90)
                                .shadow(color: .black, radius: 10)
                                .animation(
                                    .easeInOut(duration: 1.4)
                                        .repeatForever(autoreverses: true),
                                    value: showText
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)

                        // 🌊 Pulse Layer
                        PulseLayer(pulses: pulse.pulses)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        pulse.spawnPulse(at: center)
                        UIImpactFeedbackGenerator(style: .medium)
                            .impactOccurred()

                        withAnimation(.easeInOut(duration: 0.25)) {
                            showText = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            navigate = true
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                pulse.spawnPulse(at: value.location)
                            }
                    )
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showText = true
                }
            }
            .navigationDestination(isPresented: $navigate) {
                FooterTabView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
