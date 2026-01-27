//
//  StoryListView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import SwiftUI

struct StoryListView: View {

    @ObservedObject var viewModel: StoryViewModel
    @State private var expandedChapterId: String?

    var body: some View {
        List {
            ForEach(viewModel.chapters) { chapter in

                Section {
                    if expandedChapterId == chapter.id {
                        ForEach(chapter.sections) { section in
                            StorySectionRow(
                                chapter: chapter,
                                section: section,
                                viewModel: viewModel
                            )
                        }
                    }
                } header: {
                    ChapterHeader(
                        chapter: chapter,
                        isExpanded: expandedChapterId == chapter.id
                    ) {
                        withAnimation {
                            expandedChapterId =
                                expandedChapterId == chapter.id
                                ? nil
                                : chapter.id
                        }
                    }
                }
            }
        }
    }
}
