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
        NavigationStack {
            StoryListView(viewModel: viewModel)
                .navigationTitle("Story")
                .navigationDestination(item: $viewModel.activeDialog) {
                    dialog in
                    StoryDialogView(dialog: dialog) {
                        viewModel.continueAfterDialog()

                        guard
                            let chapter = viewModel.selectedChapter,
                            let section = viewModel.selectedSection
                        else { return }

                        // ✅ IMMER nach Section-Dialog → Fight
                        onStartFight(chapter, section)
                    }
                }
        }
    }
}
