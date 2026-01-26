//
//  VictoryHeader.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct VictoryHeader: View {

    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 12) {

            // TOP LINE
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 180, height: 1)

            // TITLE
            Text(title)
                .font(.system(size: 34, weight: .heavy))
                .tracking(2.4)
                .foregroundStyle(.white)

            // SUBTITLE
            if let subtitle {
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.7))
            }

            // BOTTOM LINE
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 140, height: 1)
        }
    }
}
