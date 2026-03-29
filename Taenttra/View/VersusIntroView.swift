//
//  VersusIntroView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct VersusIntroView: View {
    let stage: VersusStage
    let enemyName: String
    let onStart: () -> Void

    @State private var show = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 28) {
                VStack(spacing: 18) {
                    Text(stage.name.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.58))
                        .tracking(2)
                        .opacity(show ? 1 : 0)
                        .offset(y: show ? 0 : -10)

                    Text("VERSUS")
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .orange, .white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .red.opacity(0.4), radius: 12)
                        .scaleEffect(show ? 1 : 0.7)
                        .opacity(show ? 1 : 0)

                    VStack(spacing: 8) {
                        introChip(title: "TARGET", color: .cyan)

                        Text(enemyName.uppercased())
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1.6)

                        Text("ENTER THE ARENA")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.cyan.opacity(0.22), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 28)

                Button {
                    onStart()
                } label: {
                    Text("START FIGHT")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [.white, .cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
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

    private var backgroundLayer: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            Circle()
                .fill(Color.red.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 32)

            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 36)
                .offset(x: 0, y: 120)
        }
    }

    private func introChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.4)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }
}
