//
//  HomeButtonView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct HomeButtonView: View {

    let button: HomeButton
    @State private var isPressed = false
    @State private var glowPulse = false

    var body: some View {
        VStack {

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: button.iconColor).opacity(0.9),
                                Color(hex: button.iconColor).opacity(0.6),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color(hex: button.iconColor).opacity(0.6),
                        radius: 18
                    )
                    .scaleEffect(glowPulse ? 1.03 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.6)
                            .repeatForever(autoreverses: true),
                        value: glowPulse
                    )

                // 🔤 TEXT STATT ICON
                Text(button.title.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
            }
            .frame(height: 90)
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.75),
                value: isPressed
            )
        }
        .frame(maxWidth: .infinity)
        .onAppear { glowPulse = true }
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}
