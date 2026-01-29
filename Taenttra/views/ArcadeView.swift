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
            List {
                ForEach(viewModel.stages) { stage in
                    Button {
                        viewModel.select(stage)
                        onStartArcade(stage)
                    } label: {
                        ArcadeStageRow(stage: stage)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())  // 🔥 volle Breite
                    .padding(.vertical, 6)
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stage.title)
                                .font(.headline)
                            Text("WAVES: \(stage.waves)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Arcade")
    }
}
