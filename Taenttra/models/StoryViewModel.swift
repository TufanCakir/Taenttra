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

final class StoryViewModel: ObservableObject {

    // MARK: - Published State
    @Published var activeDialog: StoryDialog?
    @Published var pendingFight: (StoryChapter, StorySection)?
    @Published var chapters: [StoryChapter] = []

    @Published var selectedChapter: StoryChapter?
    @Published var selectedSection: StorySection?

    // 🔓 Story Progress
    @Published var unlockedSectionIds: Set<String> = ["1_1"]

    // MARK: - Init
    init() {
        chapters = StoryLoader.load().chapters
    }

    // MARK: - Section Handling
    func startSection(_ chapter: StoryChapter, _ section: StorySection) {
        guard isSectionUnlocked(section) else { return }

        selectedChapter = chapter
        selectedSection = section
        pendingFight = (chapter, section)

        // 🎵 STORY MUSIC
        let music = section.music ?? chapter.music
        AudioManager.shared.playSong(key: music)

        // 📖 Dialog
        activeDialog = section.introDialog
    }

    func continueAfterDialog() {
        activeDialog = nil
    }

    // MARK: - Unlock Logic
    func unlockNextSection(after section: StorySection) {
        guard
            let chapter = selectedChapter,
            let index = chapter.sections.firstIndex(where: {
                $0.id == section.id
            })
        else { return }

        let nextIndex = index + 1
        guard chapter.sections.indices.contains(nextIndex) else { return }

        let nextSection = chapter.sections[nextIndex]
        unlockedSectionIds.insert(nextSection.id)
    }

    func isSectionUnlocked(_ section: StorySection) -> Bool {
        unlockedSectionIds.contains(section.id)
    }
}
