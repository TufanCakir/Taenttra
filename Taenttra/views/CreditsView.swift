//
//  CreditsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct CreditsView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Project
                sectionCard {
                    VStack(alignment: .leading, spacing: 8) {

                        Text("TAENTTRA")
                            .font(.title2.weight(.bold))

                        Text(
                            """
                            Ein Fighting-Game-Projekt.
                            Ein Experiment über Spielgefühl, Klarheit und Fokus.
                            """
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Creator
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {

                        Text("DESIGN · CODE · ART")
                            .font(.headline.weight(.semibold))

                        Text("Tufan Cakir")
                            .font(.body.weight(.medium))
                    }
                }

                // MARK: - Thank You
                sectionCard {
                    VStack(alignment: .leading, spacing: 8) {

                        Text("DANKE")
                            .font(.headline.weight(.semibold))

                        Text(
                            "Danke fürs Spielen und fürs Unterstützen unabhängiger Spieleentwicklung."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color.black.opacity(0.03))
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Card Wrapper
    private func sectionCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
    }
}
