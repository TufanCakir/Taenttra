//
//  HeaderDetailSheet.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct HeaderDetailSheet: View {

    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var crystalManager: CrystalManager
    @EnvironmentObject var accountManager: AccountLevelManager
    @EnvironmentObject var artefacts: ArtefactInventoryManager

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            List {

                Section("Account") {
                    hudRow(
                        key: "level",
                        title: "Level",
                        value: "\(accountManager.level)"
                    )
                }

                Section("Währungen") {
                    hudRow(
                        key: "coin",
                        title: "Coins",
                        value: "\(coinManager.coins)"
                    )

                    hudRow(
                        key: "crystal",
                        title: "Crystals",
                        value: "\(crystalManager.crystals)"
                    )

                    hudRow(
                        key: "shards",
                        title: "Artefakt-Shards",
                        value: "\(artefacts.totalShards)"
                    )
                }
            }
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

@ViewBuilder
private func hudRow(
    key: String,
    title: String,
    value: String
) -> some View {

    let icon = HudIconManager.shared.icon(for: key)

    HStack {
        if let icon {
            Image(systemName: icon.symbol)
                .foregroundColor(Color(hex: icon.color))
                .frame(width: 24)
        }

        Text(title)

        Spacer()

        Text(value)
            .fontWeight(.semibold)
            .contentTransition(.numericText())
    }
}
