//
//  StoryListView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct StoryListView: View {
    @ObservedObject var viewModel: StoryViewModel
    @State private var expandedChapterId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("CHAPTER ROUTES")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.pink)

                Spacer()

                Circle()
                    .fill(Color.pink)
                    .frame(width: 8, height: 8)
            }

            if viewModel.chapters.isEmpty {
                VStack(spacing: 10) {
                    Text("NO STORY DATA")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Story chapters will appear here once the story data is available.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 42)
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.chapters) { chapter in
                        ChapterHeader(
                            chapter: chapter,
                            isExpanded: expandedChapterId == chapter.id
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                expandedChapterId =
                                    expandedChapterId == chapter.id
                                    ? nil
                                    : chapter.id
                            }
                        }

                        if expandedChapterId == chapter.id {
                            VStack(spacing: 12) {
                                ForEach(chapter.sections) { section in
                                    StorySectionRow(
                                        chapter: chapter,
                                        section: section,
                                        viewModel: viewModel
                                    )
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.pink.opacity(0.24), lineWidth: 1)
                )
                .shadow(color: Color.pink.opacity(0.12), radius: 12)
        )
    }
}
