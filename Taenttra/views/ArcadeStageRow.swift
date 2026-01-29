//
//  ArcadeStageRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 29.01.26.
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
                .frame(height: 120)
                .clipped()

            // 🌑 GRADIENT OVERLAY
            LinearGradient(
                colors: [
                    .black.opacity(0.15),
                    .black.opacity(0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 📝 TEXT CONTENT
            VStack(alignment: .leading, spacing: 6) {
                Text(stage.title)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Text("👊 \(stage.enemy.uppercased())")
                    Text("🌊 \(stage.waves) WAVES")
                    Text("⏱ \(stage.timeLimit)s")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .cornerRadius(12)
    }
}
