//
//  TrainingView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct TrainingView: View {

    @ObservedObject var viewModel: TrainingViewModel
    let onStartTraining: (TrainingMode) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.modes) { mode in
                    Button {
                        viewModel.select(mode)
                        onStartTraining(mode)
                    } label: {
                        ZStack(alignment: .bottomLeading) {

                            // 🖼 Background / Arena Image
                            Image(mode.background)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()

                            // 🌑 Gradient für Lesbarkeit
                            LinearGradient(
                                colors: [
                                    .black.opacity(0.0),
                                    .black.opacity(0.8),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )

                            // 📝 Text Overlay
                            VStack(alignment: .leading, spacing: 6) {

                                Text(mode.title)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                HStack(spacing: 8) {

                                    Text(trainingTag(for: mode))
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(tagColor(for: mode))
                                        .cornerRadius(6)

                                    Text("VS \(mode.enemy.uppercased())")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.7))

                                    if mode.timeLimit < 100 {
                                        Text("ADVANCED")
                                            .font(.caption2.bold())
                                            .foregroundColor(.red)
                                    }

                                    Text("TIME: \(mode.timeLimit)s")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .padding()
                        }
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 6)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Training")
        }
    }

    // MARK: - Helpers

    private func trainingTag(for mode: TrainingMode) -> String {
        mode.title.contains("COMBO") ? "COMBOS" : "BASICS"
    }

    private func tagColor(for mode: TrainingMode) -> Color {
        mode.title.contains("COMBO")
            ? .purple.opacity(0.8)
            : .blue.opacity(0.8)
    }
}
