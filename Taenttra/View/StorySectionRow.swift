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
            ZStack(alignment: .bottomLeading) {
                Image(section.arena)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 146)
                    .clipped()

                LinearGradient(
                    colors: [
                        .black.opacity(0.12),
                        .black.opacity(0.88),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        infoBadge("WAVES", value: "\(section.waves)")
                        if section.boss == true {
                            infoBadge("BOSS", value: "YES", accent: .red)
                        }
                        Spacer()
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title.uppercased())
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("\(section.enemies.count) ENEMIES  •  \(section.timeLimit) SEC")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(1.4)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                }
                .padding(16)

                if sectionIsLocked {
                    Color.black.opacity(0.65)

                    Text("LOCKED")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.4)
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
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        sectionIsLocked
                            ? Color.white.opacity(0.12)
                            : (section.boss == true ? Color.red.opacity(0.45) : Color.cyan.opacity(0.35)),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: section.boss == true ? Color.red.opacity(0.15) : Color.cyan.opacity(0.1),
                radius: 12,
                y: 8
            )
        }
        .disabled(sectionIsLocked)
        .animation(.easeInOut, value: sectionIsLocked)
    }

    private func infoBadge(
        _ title: String,
        value: String,
        accent: Color = .cyan
    ) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1.1)

            Text(value)
                .font(.system(size: 9, weight: .black, design: .rounded))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(accent))
    }
}
