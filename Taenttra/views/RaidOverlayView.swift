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
        VStack(spacing: 16) {

            // ❤️ RAID HP BAR
            if let hp = game.raidCurrentHP,
                let max = game.raidMaxHP,
                max > 0
            {

                let percent = CGFloat(hp) / CGFloat(max)

                ZStack {
                    // Background
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                        .frame(height: 28)

                    // HP fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.red,
                                    Color.orange,
                                    Color(red: 0.6, green: 0.1, blue: 0.1),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: 320 * percent,
                            height: 28
                        )
                        .animation(
                            .easeInOut(duration: 0.35),
                            value: hp
                        )

                    // Text Overlay
                    Text("\(hp) / \(max)")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
                .frame(width: 320, height: 28)
                .clipShape(Capsule())
                .shadow(color: .red.opacity(0.6), radius: 8)

            } else {
                // ⏳ Loading state
                Text("⏳ Lade Raid…")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
