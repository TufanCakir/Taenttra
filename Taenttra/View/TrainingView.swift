//
//  TrainingView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct TrainingView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let heroHeight: CGFloat = 212
    }

    @ObservedObject var viewModel: TrainingViewModel
    @EnvironmentObject var gameState: GameState

    let onStartTraining: (TrainingMode) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundLayer

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VersusHeaderView()

                    heroCard

                    modeSection
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.02, green: 0.07, blue: 0.14),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.15))
                .frame(width: 340, height: 340)
                .blur(radius: 42)
                .offset(x: 140, y: 160)

            Circle()
                .fill(Color.green.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 36)
                .offset(x: -120, y: -220)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.36),
                            Color.green.opacity(0.16),
                            Color.black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )

            Circle()
                .fill(Color.cyan.opacity(0.22))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .offset(x: 136, y: -30)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    hubChip(title: "TRAINING", color: .cyan)
                    Spacer()
                    hubChip(title: "\(viewModel.modes.count) MODES", color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("DOJO CONTROL")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Refine basics, run combo drills, and warm up against controlled opponents.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: .cyan.opacity(0.18), radius: 20)
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TRAINING ROUTINES")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.cyan)

                Spacer()

                Circle()
                    .fill(Color.cyan)
                    .frame(width: 8, height: 8)
            }

            if viewModel.modes.isEmpty {
                VStack(spacing: 10) {
                    Text("NO TRAINING MODES")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Add training data to load available dojo routines.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 42)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.modes, id: \.id) { mode in
                        Button {
                            viewModel.select(mode)
                            onStartTraining(mode)
                        } label: {
                            TrainingModeRow(mode: mode)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(18)
        .background(sectionBackground(accent: .cyan))
    }

    private func hubChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func sectionBackground(accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(accent.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: accent.opacity(0.12), radius: 12)
    }
}
