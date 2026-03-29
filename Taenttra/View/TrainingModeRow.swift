//
//  TrainingModeRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct TrainingModeRow: View {
    let mode: TrainingMode

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(mode.background)
                .resizable()
                .scaledToFill()
                .frame(height: 164)
                .clipped()
                .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    .black.opacity(0.12),
                    .black.opacity(0.9),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    statBadge(trainingTag(for: mode), accent: tagColor(for: mode))
                    Spacer()
                    if mode.timeLimit < 100 {
                        statBadge("ADVANCED", accent: .orange)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        statBadge("VS \(mode.enemy.uppercased())", accent: .white)
                        statBadge(mode.timeLimit < 100 ? "TIME \(mode.timeLimit)S" : "TIME ∞", accent: .cyan)
                    }
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.6),
            radius: 10,
            y: 6
        )
    }

    private func trainingTag(for mode: TrainingMode) -> String {
        mode.title.contains("COMBO") ? "COMBOS" : "BASICS"
    }

    private func tagColor(for mode: TrainingMode) -> Color {
        mode.title.contains("COMBO")
            ? Color.purple.opacity(0.8)
            : Color.cyan.opacity(0.8)
    }

    private func statBadge(_ title: String, accent: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(accent))
            .foregroundStyle(.black)
    }
}
