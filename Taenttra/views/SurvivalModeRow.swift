//
//  SurvivalModeRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 29.01.26.
//

import SwiftUI

struct SurvivalModeRow: View {

    let mode: SurvivalMode

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // 🖼 BACKGROUND
            Image(mode.background)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()

            // 🌑 GRADIENT
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
                Text(mode.title)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Text("⏱ \(mode.timeLimit)s")
                    Text("👊 \(mode.enemyPool.count) ENEMIES")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .cornerRadius(12)
    }
}
