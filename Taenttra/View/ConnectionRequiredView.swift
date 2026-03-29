//
//  ConnectionRequiredView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ConnectionRequiredView: View {
    let message: String
    @State private var pulse = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(pulse ? 0.18 : 0.1))
                        .frame(width: 118, height: 118)
                        .blur(radius: 12)

                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: 1.5)
                        .frame(width: 104, height: 104)

                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 8) {
                    Text("CONNECTION REQUIRED")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(.white)

                    Text(message)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                }

                Button {
                    retryConnection()
                } label: {
                    Text("RETRY")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.white, .cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        )
                        .shadow(color: .cyan.opacity(0.34), radius: 14)
                }
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.cyan.opacity(0.24), lineWidth: 1)
                    )
                    .shadow(color: .cyan.opacity(0.14), radius: 18)
            )
            .padding(.horizontal, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.03, green: 0.06, blue: 0.12),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 300, height: 300)
                .blur(radius: 42)
                .offset(x: -120, y: -180)

            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 46)
                .offset(x: 140, y: 180)
        }
    }
}
private func retryConnection() {
    // Placeholder for future reconnect handling.
}
