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
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 20) {

            Text("Select Background")
                .font(.largeTitle.bold())

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {

                    ForEach(Array(bgManager.owned), id: \.self) { style in
                        backgroundTile(style)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Backgrounds")
    }

    // MARK: - Tile
    @ViewBuilder
    private func backgroundTile(_ style: BackgroundStyle) -> some View {
        Button {
            withAnimation(.easeInOut) {
                bgManager.select(style)
            }
        } label: {
            ZStack(alignment: .topTrailing) {

                SpiritGridBackground(style: style)
                    .frame(height: 120)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                bgManager.selected == style
                                    ? Color.green
                                    : Color.white.opacity(0.15),
                                lineWidth: 3
                            )
                    )

                // ✅ Selected Badge
                if bgManager.selected == style {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
