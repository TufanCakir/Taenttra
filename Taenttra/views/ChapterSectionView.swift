//
//  ChapterSectionView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import SwiftUI

struct ChapterSectionView: View {

    let chapter: StoryChapter
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        Section(header: Text(chapter.title)) {
            ForEach(chapter.sections) { section in
                StorySectionRow(
                    chapter: chapter,
                    section: section,
                    viewModel: viewModel
                )
            }
        }
    }
}
