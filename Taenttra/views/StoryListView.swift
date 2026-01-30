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
        ScrollView {
            VStack(spacing: 14) {

                ForEach(viewModel.chapters) { chapter in

                    ChapterHeader(
                        chapter: chapter,
                        isExpanded: expandedChapterId == chapter.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            expandedChapterId =
                                expandedChapterId == chapter.id
                                ? nil
                                : chapter.id
                        }
                    }

                    if expandedChapterId == chapter.id {
                        VStack(spacing: 12) {
                            ForEach(chapter.sections) { section in
                                StorySectionRow(
                                    chapter: chapter,
                                    section: section,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
        }
        .background(Color.black)
    }
}
