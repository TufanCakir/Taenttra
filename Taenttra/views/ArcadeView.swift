//
//  ArcadeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct ArcadeView: View {

    @ObservedObject var viewModel: ArcadeViewModel
    let onStartArcade: (ArcadeStage) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(viewModel.stages) { stage in
                            Button {
                                viewModel.select(stage)
                                onStartArcade(stage)
                            } label: {
                                ArcadeStageRow(stage: stage)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                    .padding(12)
                }
            }
            .navigationTitle("ARCADE")
        }
    }
}
