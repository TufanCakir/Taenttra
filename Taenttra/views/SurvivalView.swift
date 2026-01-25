//
//  SurvivalView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct SurvivalView: View {

    @ObservedObject var viewModel: SurvivalViewModel
    let onStartSurvival: (SurvivalMode) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.modes) { mode in
                    Button {
                        viewModel.select(mode)
                        onStartSurvival(mode)   // ✅ nur Intent
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.title)
                                    .font(.headline)

                                Text("TIME: \(mode.timeLimit)s")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "timer")
                                .opacity(0.5)
                        }
                    }
                }
            }
            .navigationTitle("Survival")
        }
    }
}
