//
//  CreditsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct CreditsView: View {

    var body: some View {
        List {
            Section {
                Text("Taenttra ist ein Fighting-Game-Projekt.")
                Text("Ein Experiment über Spielgefühl, Klarheit und Fokus.")
                    .foregroundStyle(.secondary)

                Divider()

                Text("Design, Code & Art")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Tufan Cakir")
            }
        }
        .navigationTitle("Credits")
    }
}
