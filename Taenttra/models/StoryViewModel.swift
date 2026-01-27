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

    @Published var activeDialog: StoryDialog?
    @Published var pendingFight: (StoryChapter, StorySection)?
    @Published var chapters: [StoryChapter] = []
    @Published var selectedChapter: StoryChapter?
    @Published var selectedSection: StorySection?

    init() {
        chapters = StoryLoader.load().chapters
    }

    func startSection(_ chapter: StoryChapter, _ section: StorySection) {

        selectedChapter = chapter
        selectedSection = section
        pendingFight = (chapter, section)

        // 🎵 STORY-MUSIK (Section > Chapter)
        let music = section.music ?? chapter.music
        AudioManager.shared.playSong(key: music)

        // 📖 Dialog anzeigen
        if let dialog = section.introDialog {
            activeDialog = dialog
        } else {
            activeDialog = nil
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
