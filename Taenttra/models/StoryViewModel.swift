//
//  StoryViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Combine
import Foundation

enum DialogPhase {
    case chapter
    case section
}

@MainActor
final class StoryViewModel: ObservableObject {

    @Published var activeDialog: StoryDialog?
    @Published var pendingFight: (StoryChapter, StorySection)?
    @Published var chapters: [StoryChapter] = []
    @Published var selectedChapter: StoryChapter?
    @Published var selectedSection: StorySection?

    init() {
        Task { await loadStory() }
    }

    func loadStory() async {
        if let story = await StoryLoader.load() {
            self.chapters = story.chapters
            print("✅ loaded chapters:", story.chapters.count)
            print(
                "✅ loaded sections:",
                story.chapters.first?.sections.map(\.id) ?? []
            )
        } else {
            print("❌ story is nil")
        }
    }

    func startSection(_ chapter: StoryChapter, _ section: StorySection) {

        selectedChapter = chapter
        selectedSection = section
        pendingFight = (chapter, section)

        let tags = Set((chapter.odrTags ?? []) + (section.odrTags ?? []))

        ODRManager.shared.load(tags: tags) { _ in
            let music = section.music ?? chapter.music
            AudioManager.shared.playSong(key: music)
            self.activeDialog = section.introDialog
        }
    }

    func continueAfterDialog() {
        activeDialog = nil
    }
}

func resolvedMusic(
    chapter: StoryChapter,
    section: StorySection
) -> String {
    section.music ?? chapter.music
}
