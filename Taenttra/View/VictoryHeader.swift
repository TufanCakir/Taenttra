//
//  VictoryHeader.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct VictoryHeader: View {

    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 14) {

            // 🔱 TOP ACCENT
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.05), .white.opacity(0.4),
                            .white.opacity(0.05),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 220, height: 2)

            // 🏆 TITLE
            Text(title)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 6, y: 2)

            // ✨ SUBTITLE
            if let subtitle {
                Text(subtitle.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.75))
            }

            // 🔱 BOTTOM ACCENT
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 160, height: 1.5)
        }
        .padding(.vertical, 12)
    }
}
