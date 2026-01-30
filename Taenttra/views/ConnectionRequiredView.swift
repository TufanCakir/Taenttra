//
//  ConnectionRequiredView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct ConnectionRequiredView: View {

    let message: String
    @State private var pulse = false

    var body: some View {
        ZStack {

            // 🌑 BASE BACKGROUND
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ✨ CYAN GLOW
            RadialGradient(
                colors: [
                    Color.cyan.opacity(pulse ? 0.35 : 0.15),
                    .clear,
                ],
                center: .center,
                startRadius: 40,
                endRadius: 260
            )
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: pulse
            )

            VStack(spacing: 26) {

                // 📡 ICON
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .cyan.opacity(0.6), radius: 20)

                // 🧾 TITLE
                Text("CONNECTION REQUIRED")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(2)
                    .foregroundColor(.white)

                // 💬 MESSAGE
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // 🔁 RETRY BUTTON
                Button {
                    GameCenterManager.shared.authenticate()
                } label: {
                    Text("RETRY")
                        .font(.system(size: 16, weight: .heavy))
                        .tracking(1.2)
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .cyan.opacity(0.6), radius: 14)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .onAppear {
            pulse = true
        }
    }
}
