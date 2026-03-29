//
//  StorySectionRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct StorySectionRow: View {

    let chapter: StoryChapter
    let section: StorySection
    @ObservedObject var viewModel: StoryViewModel

    private var sectionIsLocked: Bool {
        !viewModel.isSectionUnlocked(section)
    }

    var body: some View {
        Button {
            viewModel.startSection(chapter, section)
        } label: {
            ZStack {

                // 🖼 BACKGROUND IMAGE
                Image(section.arena)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .clipped()

                // 🌑 GRADIENT OVERLAY
                LinearGradient(
                    colors: [
                        .black.opacity(0.0),
                        .black.opacity(0.75),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 📝 TEXT
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()

                    Text(section.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(section.waves) Waves")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))

                    if section.boss == true {
                        Text("Boss Fight")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(6)
                    }
                }
                .padding()

                // 🔒 LOCK OVERLAY
                if sectionIsLocked {
                    Color.black.opacity(0.65)

                    Text("Locked")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.7))
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            Color.red.opacity(0.6),
                                            lineWidth: 1
                                        )
                                )
                        )
                }
            }
        }
        .disabled(sectionIsLocked)  // 🔥 wichtig
        .listRowInsets(.init())
        .padding(.vertical, 6)
        .animation(.easeInOut, value: sectionIsLocked)
    }
}
