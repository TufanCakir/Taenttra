//
//  RaidOverlayView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct RaidOverlayView: View {

    @EnvironmentObject var game: SpiritGameController

    var body: some View {
        VStack(spacing: 10) {

            // 🔥 RAID HEADER
            HStack {
                Text("🔥 RAID")
                    .font(.headline)
                    .foregroundColor(.red)

                Spacer()

                Text("\(game.eventBossIndex + 1) / \(game.eventBossList.count)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            // ❤️ HP BAR
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(
                    value: Double(game.currentHP),
                    total: Double(game.current.hp)
                )
                .progressViewStyle(LinearProgressViewStyle(tint: .red))

                Text("HP: \(game.currentHP)")
                    .font(.caption)
                    .foregroundColor(.white)
            }

            // 🎁 Belohnungshinweis
            if game.eventBossIndex == game.eventBossList.count - 1 {
                Text("🎁 Finale Raid-Belohnung")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }

        }
        .padding()
        .background(Color.black.opacity(0.75))
        .cornerRadius(14)
        .padding()
    }
}
