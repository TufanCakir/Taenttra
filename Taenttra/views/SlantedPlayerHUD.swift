//
//  SlantedPlayerHUD.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftUI

struct SlantedPlayerHUD: View {

    let name: String
    let health: CGFloat
    let direction: SlantDirection

    var body: some View {
        VStack(
            alignment: direction == .left ? .leading : .trailing,
            spacing: 8
        ) {

            Text(name.uppercased())
                .font(.system(size: 13, weight: .heavy))
                .tracking(1)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            Capsule()
                                .stroke(
                                    direction == .left
                                        ? Color.cyan.opacity(0.6)
                                        : Color.red.opacity(0.6),
                                    lineWidth: 1
                                )
                        )
                )

            SlantedHealthBar(
                value: health,
                direction: direction
            )
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SlantedPlayerHUD(name: "Ten", health: 1.0, direction: .left)
        SlantedPlayerHUD(name: "Rei", health: 0.35, direction: .right)
    }
    .padding()
}
