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
            Image(stage.background)
                .resizable()
                .scaledToFill()
                .frame(height: 168)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.12),
                            Color.black.opacity(0.9),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipped()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    statChip("ARCADE", color: .orange)
                    Spacer()
                    statChip("TIME \(stage.timeLimit)S", color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text(stage.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.4)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        statChip("ENEMY \(stage.enemy.uppercased())", color: .red)
                        statChip("WAVES \(stage.waves)", color: .orange)
                        statChip("TIME \(stage.timeLimit)S", color: .cyan)
                    }
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.65),
            radius: 14,
            y: 8
        )
    }

    private func statChip(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.1)
            .foregroundStyle(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color)
        )
    }
}
