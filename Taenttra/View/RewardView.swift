//
//  RewardView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct RewardView: View {
    let label: String
    let value: String
    let color: Color
    let iconName: String
    let accent: Color

    var body: some View {
        HStack(spacing: 14) {
            rewardIcon

            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(accent.opacity(0.9))

                Text("REWARD PAYOUT")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.46))
            }

            Spacer()

            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.28))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent.opacity(0.28), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var rewardIcon: some View {
        if iconName.hasPrefix("system:") {
            Image(systemName: String(iconName.dropFirst(7)))
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 40, height: 40)
                .shadow(color: accent.opacity(0.5), radius: 10)
        } else {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .shadow(color: accent.opacity(0.5), radius: 10)
        }
    }
}
