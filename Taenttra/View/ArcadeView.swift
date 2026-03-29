//
//  ArcadeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ArcadeView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let heroHeight: CGFloat = 212
    }

    @ObservedObject var viewModel: ArcadeViewModel
    @EnvironmentObject var gameState: GameState

    let onStartArcade: (ArcadeStage) -> Void

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

                    stageSection
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
                    Color(red: 0.11, green: 0.05, blue: 0.01),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.orange.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 42)
                .offset(x: 140, y: 160)

            Circle()
                .fill(Color.cyan.opacity(0.12))
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
                            Color.orange.opacity(0.38),
                            Color.yellow.opacity(0.14),
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
                .fill(Color.orange.opacity(0.24))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .offset(x: 136, y: -30)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    hubChip(title: "ARCADE", color: .orange)
                    Spacer()
                    hubChip(title: "\(viewModel.stages.count) STAGES", color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("TOWER RUN")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Climb through staged battles, clear fixed wave routes, and push deeper into the arcade ladder.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: .orange.opacity(0.18), radius: 20)
    }

    private var stageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ARCADE STAGES")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.orange)

                Spacer()

                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
            }

            if viewModel.stages.isEmpty {
                VStack(spacing: 10) {
                    Text("NO ARCADE STAGES")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Add arcade stage data to load the battle ladder.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 42)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.stages) { stage in
                        Button {
                            viewModel.select(stage)
                            onStartArcade(stage)
                        } label: {
                            ArcadeStageRow(stage: stage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(18)
        .background(sectionBackground(accent: .orange))
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
