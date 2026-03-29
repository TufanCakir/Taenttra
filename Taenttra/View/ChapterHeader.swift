//
//  ChapterHeader.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ChapterHeader: View {
    let chapter: StoryChapter
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(isExpanded ? 0.24 : 0.12),
                            Color.black.opacity(0.88),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            isExpanded
                                ? Color.cyan.opacity(0.55)
                                : Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                )

            if !chapter.background.isEmpty {
                Image(chapter.background)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.22)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("CHAPTER \(chapter.id)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.cyan))

                    Spacer()

                    Text(isExpanded ? "▼" : "▶")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.cyan)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title.uppercased())
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(chapter.sections.count) SECTIONS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.62))
                }
            }
            .padding(18)
        }
        .frame(height: 110)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
