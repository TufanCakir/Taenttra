//
//  ArcadeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ArcadeView: View {

    @ObservedObject var viewModel: ArcadeViewModel
    @EnvironmentObject var gameState: GameState

    let onStartArcade: (ArcadeStage) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // ⬅️ GAME BACK BUTTON
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            // 📜 CONTENT
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
                .padding(.horizontal, 12)
                .padding(.top, 80)  // 🔥 Platz für BackButton + Title
                .padding(.bottom, 24)
            }
        }
    }
}
