//
//  StoryView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct StoryView: View {

    @ObservedObject var viewModel: StoryViewModel
    @EnvironmentObject var gameState: GameState

    let onStartFight: (StoryChapter, StorySection) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // 📜 STORY LIST
            StoryListView(viewModel: viewModel)
                .padding(.top, 80)  // 🔥 gleicher Abstand wie Survival

            // ⬅️ GAME BACK BUTTON (HUD)
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(20)

            // 📖 DIALOG OVERLAY
            if let dialog = viewModel.activeDialog {
                StoryDialogView(dialog: dialog) {
                    viewModel.continueAfterDialog()

                    guard
                        let chapter = viewModel.selectedChapter,
                        let section = viewModel.selectedSection
                    else { return }

                    onStartFight(chapter, section)
                }
                .transition(.opacity)
                .zIndex(30)
            }
        }
    }
}
