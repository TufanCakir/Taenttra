//
//  StartView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct StartView: View {

    @EnvironmentObject var gameState: GameState

    @State private var showPrompt = true
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            Image("kenji_base_preview")
                .resizable()
                .scaledToFit()
                .frame(height: 500)
                .offset(y: -50)

            VStack {
                Spacer()

                Text("PRESS TO START")
                    .font(.system(size: 18, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.primary)
                    .opacity(showPrompt ? 1 : 0.3)
                    .scaleEffect(scale)
                    .padding(.bottom, 50)
            }
        }
        .onAppear { startPulse() }
        .onTapGesture {
            gameState.screen = .home
        }
    }

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
        ) {
            showPrompt.toggle()
            scale = 1.05
        }
    }
}

#Preview {
    StartView()
}
