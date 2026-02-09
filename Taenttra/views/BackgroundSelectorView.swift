//
//  BackgroundSelectorView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct BackgroundSelectorView: View {

    @EnvironmentObject private var bgManager: BackgroundManager

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        ZStack {
            // 🌌 App Background
            SpiritGridBackground(style: bgManager.selected)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                header

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(
                            bgManager.owned.sorted(by: {
                                $0.rawValue < $1.rawValue
                            }),
                            id: \.self
                        ) { style in
                            backgroundTile(style)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Backgrounds")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Choose your global app background")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.25),
                    .clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    @ViewBuilder
    private func backgroundTile(_ style: BackgroundStyle) -> some View {
        let isSelected = bgManager.selected == style

        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                bgManager.select(style)
            }
        } label: {
            VStack(spacing: 0) {

                ZStack(alignment: .topTrailing) {

                    SpiritGridBackground(style: style)
                        .frame(height: 110)
                        .clipped()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(6)
                    }
                }

                // 🔹 Name Bar
                Text(style.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.45))
            }
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected
                            ? Color.green.opacity(0.9)
                            : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .shadow(
                color: isSelected
                    ? Color.green.opacity(0.45)
                    : .black.opacity(0.3),
                radius: isSelected ? 14 : 8,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
}
