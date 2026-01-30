//
//  CreditsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct CreditsView: View {

    var body: some View {
        ZStack {
            // 🖤 GAME BACKGROUND
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Project
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {

                            Text("TAENTTRA")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)

                            Text(
                                """
                                Ein Fighting-Game-Projekt.
                                Ein Experiment über Spielgefühl, Klarheit und Fokus.
                                """
                            )
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                        }
                    }

                    // MARK: - Creator
                    sectionCard {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("DESIGN · CODE · ART")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.cyan)

                            Text("Tufan Cakir")
                                .font(.body.weight(.medium))
                                .foregroundColor(.white)
                        }
                    }

                    // MARK: - Thank You
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {

                            Text("DANKE")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)

                            Text(
                                "Danke fürs Spielen und fürs Unterstützen unabhängiger Spieleentwicklung."
                            )
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("CREDITS")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Card Wrapper
    private func sectionCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))  // 🎮 Game-Card
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}
