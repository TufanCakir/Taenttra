//
//  StoryView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct StoryView: View {

    @ObservedObject var viewModel: StoryViewModel
    let onStartFight: (StoryChapter, StorySection) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            StoryListView(viewModel: viewModel)

            // 📖 DIALOG OVERLAY (GAME-STYLE)
            if let dialog = viewModel.activeDialog {
                StoryDialogView(dialog: dialog) {
                    viewModel.continueAfterDialog()

                    guard
                        let chapter = viewModel.selectedChapter,
                        let section = viewModel.selectedSection
                    else { return }

                    // 🔥 HIER ist der entscheidende Übergang
                    onStartFight(chapter, section)
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
    }
}
