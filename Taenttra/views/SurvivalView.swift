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
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.modes) { mode in
                        Button {
                            viewModel.select(mode)
                            onStartSurvival(mode)
                        } label: {
                            SurvivalModeRow(mode: mode)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
        }
        .navigationTitle("SURVIVAL")
        .navigationBarTitleDisplayMode(.inline)
    }
}
