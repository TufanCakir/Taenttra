//
//  StoryViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation
import Combine

final class StoryViewModel: ObservableObject {

    @Published var chapters: [StoryChapter] = []
    @Published var selectedChapter: StoryChapter?
    @Published var selectedSection: StorySection?

    init() {
        chapters = StoryLoader.load().chapters
    }

    func select(_ chapter: StoryChapter, _ section: StorySection) {
        selectedChapter = chapter
        selectedSection = section
    }
}


