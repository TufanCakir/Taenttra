//
//  KOView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct KOView: View {
    let winnerSide: FighterSide
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.4
    @State private var opacity: CGFloat = 0
    @State private var flash = false
    @State private var showContinue = false
    @State private var shake: CGFloat = 0
    @State private var showDefeatToast = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 20) {
                Text("BATTLE FINISH")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(2.2)
                    .foregroundStyle(.white.opacity(0.52))

                Text("K.O.")
                    .font(.system(size: 104, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.red.opacity(0.9), lineWidth: 3)
                            .mask(
                                Text("K.O.")
                                    .font(.system(size: 104, weight: .black))
                            )
                    )
                    .shadow(color: .red.opacity(0.9), radius: 12)  // statt 20+
                    .offset(x: shake)

                VStack(spacing: 10) {
                    Text(winnerText)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundColor(winnerColor)
                        .shadow(color: winnerColor.opacity(0.9), radius: 14)

                    Text(statusSubtitle)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.5))
                }

                if winnerSide != .left {
                    defeatInfoCard
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(26)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(winnerColor.opacity(0.28), lineWidth: 1)
                    )
                    .shadow(color: winnerColor.opacity(0.16), radius: 20)
            )
            .padding(.horizontal, 28)
            .scaleEffect(scale)
            .opacity(opacity)

            if showContinue {
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .tracking(1.8)
                        .scaleEffect(showContinue ? 1.0 : 0.95)
                        .animation(
                            .easeInOut(duration: 0.9).repeatForever(
                                autoreverses: true
                            ),
                            value: showContinue
                        )
                        .foregroundColor(.black)
                        .padding(.horizontal, 54)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    winnerColor.opacity(0.95),
                                    .white,
                                    winnerColor.opacity(0.78),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.24), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        .shadow(color: winnerColor.opacity(0.9), radius: 18)
                }
                .padding(.top, 350)
                .transition(.scale.combined(with: .opacity))
            }

            if showDefeatToast {
                RewardToastOverlay(
                    heading: "BATTLE REPORT",
                    entries: defeatToastEntries
                ) {
                    showDefeatToast = false
                }
            }
        }
        .background(
            flash ? Color.red.opacity(0.6) : Color.clear
        )
        .onAppear {
            playAnimation()
            showDefeatToast = winnerSide != .left
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            Color.black
                .opacity(0.78)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    winnerColor.opacity(0.16),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.92),
                ],
                center: .center,
                startRadius: 120,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }

    private var winnerText: String {
        winnerSide == .left ? "PLAYER WINS" : "ENEMY WINS"
    }

    private var statusSubtitle: String {
        winnerSide == .left ? "PRESS CONTINUE" : "RETRY AND BREAK THE STREAK"
    }

    private var winnerColor: Color {
        winnerSide == .left ? .cyan : .red
    }

    private var defeatToastEntries: [RewardToastEntry] {
        [
            RewardToastEntry(
                label: "Battle",
                value: "NO PAYOUT",
                color: .red,
                iconName: "system:xmark.octagon.fill",
                accent: .red
            ),
            RewardToastEntry(
                label: "Retry",
                value: "READY",
                color: .yellow,
                iconName: "system:arrow.clockwise.circle.fill",
                accent: .yellow
            ),
        ]
    }

    private var defeatInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DEFEAT STATUS")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.red.opacity(0.9))

            Text("No battle payout this round. Re-enter the arena and push your win chain forward.")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.red.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func playAnimation() {
        flash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            flash = false
        }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
            scale = 1
            opacity = 1
        }

        withAnimation(
            .easeInOut(duration: 0.06).repeatCount(4, autoreverses: true)
        ) {
            shake = 10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            shake = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showContinue = true
            }
        }
    }
}
