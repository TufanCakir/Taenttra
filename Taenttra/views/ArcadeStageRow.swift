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
                .frame(height: 130)
                .clipped()

            // 🌑 DARK OVERLAY
            LinearGradient(
                colors: [
                    .black.opacity(0.15),
                    .black.opacity(0.9),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 📝 CONTENT
            VStack(alignment: .leading, spacing: 6) {

                Text(stage.title.uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                HStack(spacing: 16) {

                    Text("ENEMY: \(stage.enemy.uppercased())")

                    Text("\(stage.waves) WAVES")

                    Text("\(stage.timeLimit)s")
                }
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
            }
            .padding(14)
        }
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.6),
            radius: 10,
            y: 6
        )
    }
}
