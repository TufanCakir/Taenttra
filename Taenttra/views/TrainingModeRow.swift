//
//  TrainingModeRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 29.01.26.
//

import SwiftUI

struct TrainingModeRow: View {

    let mode: TrainingMode

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // 🖼 BACKGROUND
            Image(mode.background)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .allowsHitTesting(false)

            // 🌑 SOFTER GRADIENT
            LinearGradient(
                colors: [
                    .black.opacity(0.15),
                    .black.opacity(0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 📝 CONTENT
            VStack(alignment: .leading, spacing: 6) {

                Text(mode.title.uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                HStack(spacing: 14) {

                    Text(trainingTag(for: mode))
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(tagColor(for: mode))
                        )

                    Text("VS \(mode.enemy.uppercased())")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))

                    if mode.timeLimit < 100 {
                        Text("ADVANCED")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.red)
                    }

                    Text("TIME ∞")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(14)
        }
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.6),
            radius: 10,
            y: 6
        )
    }

    // MARK: - Helpers

    private func trainingTag(for mode: TrainingMode) -> String {
        mode.title.contains("COMBO") ? "COMBOS" : "BASICS"
    }

    private func tagColor(for mode: TrainingMode) -> Color {
        mode.title.contains("COMBO")
            ? Color.purple.opacity(0.8)
            : Color.cyan.opacity(0.8)
    }
}
