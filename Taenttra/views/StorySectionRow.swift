//
//  StorySectionRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import SwiftUI

struct StorySectionRow: View {

    let chapter: StoryChapter
    let section: StorySection
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        Button {
            viewModel.startSection(chapter, section)
        } label: {
            HStack {
                Text(section.title)
                Spacer()
                if section.boss == true {
                    Text("BOSS")
                        .foregroundStyle(.red)
                        .font(.caption.bold())
                }
            }
        }
        .buttonStyle(.plain)
    }
}
