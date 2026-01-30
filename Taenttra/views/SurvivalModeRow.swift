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
                .frame(height: 130)
                .clipped()

            // 🌑 HEAVY GRADIENT
            LinearGradient(
                colors: [
                    .black.opacity(0.25),
                    .black.opacity(0.9),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 📝 CONTENT
            VStack(alignment: .leading, spacing: 8) {

                Text(mode.title.uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                HStack(spacing: 14) {

                    // TIME
                    Text("TIME \(mode.timeLimit)s")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white.opacity(0.85))

                    // ENEMIES
                    Text("\(mode.enemyPool.count) ENEMIES")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.red)

                    // TAG
                    Text("SURVIVAL")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.8))
                        )
                }
            }
            .padding(14)
        }
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.red.opacity(0.35), lineWidth: 1.2)
        )
        .shadow(
            color: Color.red.opacity(0.25),
            radius: 14,
            y: 8
        )
    }
}
