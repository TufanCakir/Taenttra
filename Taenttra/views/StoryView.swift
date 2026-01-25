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
            List {
                ForEach(viewModel.chapters) { chapter in
                    Section(header: Text(chapter.title)) {
                        ForEach(chapter.sections) { section in
                            Button {
                                viewModel.select(chapter, section)
                                onStartFight(chapter, section)  // ✅ KORREKT
                            } label: {
                                HStack {
                                    Text(section.id.uppercased())
                                    Spacer()
                                    if section.boss == true {
                                        Text("BOSS")
                                            .foregroundColor(.red)
                                            .bold()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Story")
        }
    }
}
