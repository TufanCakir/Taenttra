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
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(viewModel.modes, id: \.id) { mode in
                            Button {
                                viewModel.select(mode)
                                onStartTraining(mode)
                            } label: {
                                TrainingModeRow(mode: mode)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                    .padding(12)
                }
            }
            .navigationTitle("TRAINING")
        }
    }
}
