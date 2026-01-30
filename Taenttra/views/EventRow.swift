//
//  EventRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 29.01.26.
//

import SwiftUI

struct EventRow: View {

    let event: EventMode

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // 🖼 BACKGROUND
            Image(event.background)
                .resizable()
                .scaledToFill()
                .frame(height: 130)
                .clipped()

            // 🌑 GRADIENT (edel, nicht aggressiv)
            LinearGradient(
                colors: [
                    .black.opacity(0.2),
                    .black.opacity(0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 📝 CONTENT
            VStack(alignment: .leading, spacing: 8) {

                HStack {
                    Text(event.title.uppercased())
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)

                    Spacer()

                    // EVENT BADGE
                    Text("EVENT")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.yellow)
                        )
                        .foregroundColor(.black)
                }

                HStack(spacing: 14) {

                    Text("TIME \(event.timeLimit)s")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white.opacity(0.85))

                    Text(event.enemy.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.yellow)
                }
            }
            .padding(14)
        }
        .cornerRadius(14)
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
}
