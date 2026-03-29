//
//  TrainingView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct TrainingView: View {

    @ObservedObject var viewModel: TrainingViewModel
    @EnvironmentObject var gameState: GameState

    let onStartTraining: (TrainingMode) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // ⬅️ GAME BACK BUTTON (HUD)
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            // 📜 CONTENT
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
                .padding(.horizontal, 12)
                .padding(.top, 80)  // 🔥 Platz für BackButton + Title
                .padding(.bottom, 24)
            }
        }
    }
}
