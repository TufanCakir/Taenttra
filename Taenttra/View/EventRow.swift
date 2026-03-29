//
//  EventRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct EventRow: View {
    let event: EventMode

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(event.background)
                .resizable()
                .scaledToFill()
                .frame(height: 164)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.14),
                    .black.opacity(0.9),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    eventBadge(title: "EVENT", color: .yellow)

                    if event.rewardShards > 0 {
                        eventBadge(title: "REWARD", color: .cyan)
                    }

                    Spacer()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        statChip("TIME", value: "\(event.timeLimit)S", accent: .white)
                        statChip("ENEMY", value: event.enemy.uppercased(), accent: .yellow)
                        if event.rewardShards > 0 {
                            statChip("SHARDS", value: "\(event.rewardShards)", accent: .cyan)
                        }
                    }
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [.yellow.opacity(0.8), .orange.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: Color.yellow.opacity(0.35),
            radius: 16,
            y: 8
        )
    }

    private func eventBadge(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.2)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(color))
            .foregroundStyle(.black)
    }

    private func statChip(_ title: String, value: String, accent: Color) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1.1)

            Text(value)
                .font(.system(size: 9, weight: .black, design: .rounded))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(accent))
    }
}
