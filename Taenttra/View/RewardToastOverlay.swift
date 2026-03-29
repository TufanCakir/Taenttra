//
//  RewardToastOverlay.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct RewardToastEntry: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let color: Color
    let iconName: String
    let accent: Color
}

struct RewardToastOverlay: View {
    let heading: String
    let entries: [RewardToastEntry]
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.58)
                .ignoresSafeArea()
                .onTapGesture(perform: dismiss)

            VStack(spacing: 16) {
                Text(heading)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.yellow)

                VStack(spacing: 10) {
                    ForEach(entries) { entry in
                        RewardView(
                            label: entry.label,
                            value: entry.value,
                            color: entry.color,
                            iconName: entry.iconName,
                            accent: entry.accent
                        )
                    }
                }

                Button(action: dismiss) {
                    Text("CONTINUE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.yellow))
                }
                .buttonStyle(.plain)
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.84))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1.2)
                    )
            )
            .padding(.horizontal, 26)
        }
        .transition(.opacity)
    }
}
