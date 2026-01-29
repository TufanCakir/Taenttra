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

            // 🌑 GRADIENT (ruhiger als Survival)
            LinearGradient(
                colors: [
                    .black.opacity(0.1),
                    .black.opacity(0.75),
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
                    Text("🧠 TRAINING")
                    Text("⏱ ∞")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .cornerRadius(12)
    }
}
