//
//  VersusIntroView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct VersusIntroView: View {

    let stage: VersusStage
    let enemyName: String
    let onStart: () -> Void

    @State private var show = false

    var body: some View {
        ZStack {
            // 🖤 Dark Backdrop
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 28) {

                // MARK: - STAGE
                Text(stage.name.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1.2)
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : -10)

                // MARK: - VERSUS
                Text("VERSUS")
                    .font(.system(size: 56, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(show ? 1 : 0.7)
                    .opacity(show ? 1 : 0)

                // MARK: - ENEMY
                VStack(spacing: 6) {

                    Text("VS")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.4))

                    Text(enemyName.uppercased())
                        .font(.title2.weight(.bold))
                        .foregroundColor(.cyan)
                        .tracking(1.4)
                }
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : 10)

                // MARK: - START BUTTON
                Button {
                    onStart()
                } label: {
                    Text("START FIGHT")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .scaleEffect(show ? 1 : 0.85)
                .opacity(show ? 1 : 0)
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                show = true
            }
        }
    }
}
