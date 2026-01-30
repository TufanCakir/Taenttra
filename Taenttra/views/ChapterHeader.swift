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
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title.uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                Text("\(chapter.sections.count) SECTIONS")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // ▶︎ / ▼ Ersatz ohne SF Symbols
            Text(isExpanded ? "▼" : "▶︎")
                .font(.caption.weight(.bold))
                .foregroundColor(.cyan)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isExpanded
                                ? Color.cyan.opacity(0.6)
                                : Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowInsets(.init())
        .padding(.vertical, 6)
    }
}
