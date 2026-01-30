//
//  LicensesView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct LicensesView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - App Info
                sectionCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TAENTTRA")
                            .font(.title2.weight(.bold))

                        Text("© 2026 Tufan Cakir")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Alle Rechte vorbehalten.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Open Source Info
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {

                        Text("OPEN-SOURCE-SOFTWARE")
                            .font(.headline.weight(.semibold))

                        Text(
                            """
                            Taenttra verwendet Open-Source-Software.
                            Die folgenden Lizenzbedingungen gelten für enthaltene Komponenten.
                            """
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Libraries
                sectionCard {
                    VStack(alignment: .leading, spacing: 8) {

                        Text("DRITTANBIETER-BIBLIOTHEKEN")
                            .font(.headline.weight(.semibold))

                        Text(
                            "Derzeit werden keine externen Drittanbieter-Bibliotheken verwendet."
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
        .navigationTitle("Lizenzen")
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

