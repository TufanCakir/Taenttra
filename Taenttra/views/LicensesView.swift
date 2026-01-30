//
//  LicensesView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct LicensesView: View {

    var body: some View {
        ZStack {
            // 🖤 GAME BACKGROUND
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - App Info
                    sectionCard {
                        VStack(alignment: .leading, spacing: 6) {

                            Text("TAENTTRA")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)

                            Text("© 2026 Tufan Cakir")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))

                            Text("Alle Rechte vorbehalten.")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.55))
                        }
                    }

                    // MARK: - Open Source Info
                    sectionCard {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("OPEN-SOURCE-SOFTWARE")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.cyan)

                            Text(
                                """
                                Taenttra verwendet Open-Source-Software.
                                Die folgenden Lizenzbedingungen gelten für enthaltene Komponenten.
                                """
                            )
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                        }
                    }

                    // MARK: - Libraries
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {

                            Text("DRITTANBIETER-BIBLIOTHEKEN")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)

                            Text(
                                "Derzeit werden keine externen Drittanbieter-Bibliotheken verwendet."
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
        .navigationTitle("LIZENZEN")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Card Wrapper (Game Panels)
    private func sectionCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}
