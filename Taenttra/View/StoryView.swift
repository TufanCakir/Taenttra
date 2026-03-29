//
//  StoryView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct StoryView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let heroHeight: CGFloat = 208
    }

    @ObservedObject var viewModel: StoryViewModel
    @EnvironmentObject var gameState: GameState

    let onStartFight: (StoryChapter, StorySection) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundLayer

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VersusHeaderView()

                    heroCard

                    StoryListView(viewModel: viewModel)
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }

            if let dialog = viewModel.activeDialog {
                StoryDialogView(dialog: dialog) {
                    viewModel.continueAfterDialog()

                    guard
                        let chapter = viewModel.selectedChapter,
                        let section = viewModel.selectedSection
                    else { return }

                    onStartFight(chapter, section)
                }
                .transition(.opacity)
                .zIndex(30)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.08, green: 0.02, blue: 0.15),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 38)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color.pink.opacity(0.12))
                .frame(width: 360, height: 360)
                .blur(radius: 46)
                .offset(x: 150, y: 160)

            AngularGradient(
                colors: [
                    .clear,
                    .white.opacity(0.08),
                    .clear,
                    .cyan.opacity(0.14),
                    .clear,
                ],
                center: .center
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.pink.opacity(0.34),
                            Color.cyan.opacity(0.16),
                            Color.black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )

            Circle()
                .fill(Color.pink.opacity(0.18))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .offset(x: 132, y: -30)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    storyStatusChip(title: "STORY", color: .pink)
                    Spacer()
                    storyStatusChip(title: "\(viewModel.chapters.count) CHAPTERS", color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("CHRONICLE MODE")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Advance chapter by chapter, clear waves, defeat bosses, and unlock the next battle route.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: .pink.opacity(0.18), radius: 20)
    }

    private func storyStatusChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }
}
