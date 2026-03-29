//
//  SurvivalModeRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct SurvivalModeRow: View {
    let mode: SurvivalMode

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(mode.background)
                .resizable()
                .scaledToFill()
                .frame(height: 164)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.14),
                    .black.opacity(0.92),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    statBadge("SURVIVAL", accent: .red)
                    Spacer()
                    statBadge("TIME \(mode.timeLimit)S", accent: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        statBadge("\(mode.enemyPool.count) ENEMIES", accent: .red)
                        statBadge(mode.enemyPool.first?.uppercased() ?? "RANDOM", accent: .orange)
                    }
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.red.opacity(0.35), lineWidth: 1.2)
        )
        .shadow(
            color: Color.red.opacity(0.25),
            radius: 14,
            y: 8
        )
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
