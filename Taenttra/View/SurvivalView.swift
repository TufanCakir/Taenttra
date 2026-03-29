//
//  SurvivalView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct SurvivalView: View {

    @ObservedObject var viewModel: SurvivalViewModel
    @EnvironmentObject var gameState: GameState

    let onStartSurvival: (SurvivalMode) -> Void

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
                    ForEach(viewModel.modes) { mode in
                        Button {
                            viewModel.select(mode)
                            onStartSurvival(mode)
                        } label: {
                            SurvivalModeRow(mode: mode)
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
