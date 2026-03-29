//
//  StoryViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Combine
import Foundation

enum DialogPhase {
    case chapter
    case section
}

@MainActor
final class StoryViewModel: ObservableObject {
    private enum Constants {
        static let initialSectionID = "1_1"
    }

    @Published var activeDialog: StoryDialog?
    @Published var pendingFight: (StoryChapter, StorySection)?
    @Published var chapters: [StoryChapter] = []

    @Published var selectedChapter: StoryChapter?
    @Published var selectedSection: StorySection?
    @Published var unlockedSectionIds: Set<String> = [Constants.initialSectionID]

    init() {
        chapters = StoryLoader.load().chapters
    }

    func startSection(_ chapter: StoryChapter, _ section: StorySection) {
        guard isSectionUnlocked(section) else { return }

        select(chapter: chapter, section: section)
        pendingFight = (chapter, section)
        AudioManager.shared.playSong(key: musicKey(for: chapter, section: section))
        activeDialog = section.introDialog
    }

    func continueAfterDialog() {
        activeDialog = nil
        pendingFight = nil
    }

    func unlockNextSection(after section: StorySection) {
        guard
            let chapter = chapter(containing: section),
            let index = sectionIndex(for: section, in: chapter)
        else { return }

        let nextIndex = index + 1
        guard chapter.sections.indices.contains(nextIndex) else { return }

        let nextSection = chapter.sections[nextIndex]
        unlockedSectionIds.insert(nextSection.id)
    }

    func isSectionUnlocked(_ section: StorySection) -> Bool {
        unlockedSectionIds.contains(section.id)
    }

    func rebuildUnlockedSections(using gameState: GameState) {
        unlockedSectionIds = [Constants.initialSectionID]

        guard let lastId = gameState.lastCompletedStorySectionId else { return }

        for chapter in chapters {
            for section in chapter.sections {
                unlockedSectionIds.insert(section.id)
                if section.id == lastId {
                    return
                }
            }
        }
    }

    private func select(chapter: StoryChapter, section: StorySection) {
        selectedChapter = chapter
        selectedSection = section
    }

    private func musicKey(for chapter: StoryChapter, section: StorySection) -> String {
        section.music ?? chapter.music
    }

    private func chapter(containing section: StorySection) -> StoryChapter? {
        if let selectedChapter,
            selectedChapter.sections.contains(where: { $0.id == section.id })
        {
            return selectedChapter
        }

        return chapters.first { chapter in
            chapter.sections.contains(where: { $0.id == section.id })
        }
    }

    private func sectionIndex(
        for section: StorySection,
        in chapter: StoryChapter
    ) -> Int? {
        chapter.sections.firstIndex(where: { $0.id == section.id })
    }
}
