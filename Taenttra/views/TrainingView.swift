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
                        onStartTraining(mode)   // ✅ nur Intent
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

                            Image(systemName: "target")
                                .opacity(0.5)
                        }
                    }
                }
            }
            .navigationTitle("Training")
        }
    }
}
