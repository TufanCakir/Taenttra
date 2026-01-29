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
                .frame(height: 120)
                .clipped()

            // 🌑 GRADIENT
            LinearGradient(
                colors: [
                    .black.opacity(0.1),
                    .black.opacity(0.8),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 📝 TEXT
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Text("⏱ \(event.timeLimit)s")
                    Text("👊 \(event.enemy.uppercased())")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .cornerRadius(12)
    }
}
