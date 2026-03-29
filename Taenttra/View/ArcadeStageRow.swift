//
//  ArcadeStageRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ArcadeStageRow: View {

    let stage: ArcadeStage

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // 🖼 BACKGROUND
            Image(stage.background)
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.05),
                            Color.black.opacity(0.85),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipped()

            // 📝 CONTENT
            VStack(alignment: .leading, spacing: 10) {

                // 🏷 TITLE
                Text(stage.title.uppercased())
                    .font(.system(size: 16, weight: .heavy))
                    .tracking(1.4)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.65))
                            .overlay(
                                Capsule()
                                    .stroke(
                                        Color.orange.opacity(0.6),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 8)

                // 📊 STATS
                HStack(spacing: 10) {

                    statChip("ENEMY", stage.enemy.uppercased(), color: .red)
                    statChip("WAVES", "\(stage.waves)", color: .orange)
                    statChip("TIME", "\(stage.timeLimit)s", color: .cyan)
                }
            }
            .padding(16)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.65),
            radius: 14,
            y: 8
        )
    }

    // MARK: - Stat Chip

    private func statChip(
        _ label: String,
        _ value: String,
        color: Color
    ) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .opacity(0.7)

            Text(value)
                .fontWeight(.bold)
        }
        .font(.caption2)
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.55))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.6), lineWidth: 1)
                )
        )
    }
}
