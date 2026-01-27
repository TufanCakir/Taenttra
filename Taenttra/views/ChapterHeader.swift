//
//  ChapterHeader.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import SwiftUI

struct ChapterHeader: View {

    let chapter: StoryChapter
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(chapter.title)
                .font(.headline)

            Spacer()

            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .padding(.vertical, 6)
    }
}
