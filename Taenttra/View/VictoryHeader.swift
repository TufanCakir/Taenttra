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
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .cyan.opacity(0.85),
                            .white.opacity(0.95),
                            .cyan.opacity(0.85),
                            .white.opacity(0.05),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 220, height: 3)

            Text(title)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(.white)
                .shadow(color: .cyan.opacity(0.34), radius: 12)

            if let subtitle {
                Text(subtitle.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.cyan))
                    .foregroundStyle(.black)
            }

            Capsule()
                .fill(Color.white.opacity(0.24))
                .frame(width: 160, height: 2)
        }
        .padding(.vertical, 12)
    }
}
