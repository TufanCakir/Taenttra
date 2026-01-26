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
            VStack(alignment: .leading, spacing: 16) {

                Text("Taenttra")
                    .font(.headline)

                Text("© 2026 Tufan Cakir. Alle Rechte vorbehalten.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Text("Open-Source-Software")
                    .font(.headline)

                Text(
                    """
                    Taenttra verwendet Open-Source-Software.
                    Die folgenden Lizenzbedingungen gelten für enthaltene Komponenten.
                    """
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Divider()

                Text(
                    "Derzeit werden keine externen Drittanbieter-Bibliotheken verwendet."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Lizenzen")
    }
}
