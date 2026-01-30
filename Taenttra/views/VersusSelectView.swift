//
//  VersusSelectView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 31.01.26.
//

import SwiftUI

struct VersusSelectView: View {

    @EnvironmentObject var gameState: GameState
    let stages: [VersusStage]

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // ⬅️ BACK
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            // 📜 STAGES
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(stages) { stage in
                        Button {
                            print("🟢 TAP on Versus Stage:", stage.id)

                            gameState.startVersusStage(stage)

                            print("🟣 after startVersusStage")
                            print("   screen =", gameState.screen)
                            print(
                                "   pendingMode =",
                                String(describing: gameState.pendingMode)
                            )
                            print(
                                "   currentStage =",
                                gameState.currentStage?.id ?? "nil"
                            )
                            print("   vm =", gameState.versusViewModel != nil)
                        } label: {
                            VersusStageRow(stage: stage)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 80)
                .padding(.bottom, 24)
            }
        }
    }
}
