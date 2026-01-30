//
//  VersusStageRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 31.01.26.
//

import SwiftUI

struct VersusStageRow: View {

    let stage: VersusStage

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

            VStack(alignment: .leading, spacing: 10) {

                // 🏷 TITLE
                Text(stage.name.uppercased())
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

                // 📊 STATS
                HStack(spacing: 10) {
                    statChip("WAVES", "\(stage.waves.count)", color: .orange)
                    statChip("ENEMIES", "\(totalEnemies)", color: .red)
                    statChip(
                        "TIME",
                        "\(stage.waves.first?.timeLimit ?? 0)s",
                        color: .cyan
                    )
                }
            }
            .padding(16)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.65), radius: 14, y: 8)
    }

    private var totalEnemies: Int {
        stage.waves.reduce(0) { $0 + $1.enemies.count }
    }

    private func statChip(
        _ label: String,
        _ value: String,
        color: Color
    ) -> some View {
        HStack(spacing: 4) {
            Text(label).opacity(0.7)
            Text(value).fontWeight(.bold)
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
