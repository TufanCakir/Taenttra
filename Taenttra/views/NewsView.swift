//
//  NewsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 06.02.26.
//

import SwiftUI

struct NewsView: View {

    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedCategory: NewsCategory?

    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {

                // 🧭 Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        categoryButton(nil, title: "ALL")

                        ForEach(NewsCategory.allCases, id: \.self) { category in
                            categoryButton(category, title: category.title)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 📰 News List
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(viewModel.items(for: selectedCategory)) {
                            item in
                            NewsRow(item: item)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
            }
            .padding(.top, 80)  // 🔥 gleicher Abstand wie StoryView

            // ⬅️ GAME BACK BUTTON (HUD)
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(20)
        }
    }

    // MARK: - Category Button
    private func categoryButton(
        _ category: NewsCategory?,
        title: String
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedCategory = category
            }
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            selectedCategory == category
                                ? Color.cyan
                                : Color.white.opacity(0.15)
                        )
                )
                .foregroundColor(
                    selectedCategory == category ? .black : .white
                )
        }
    }
}

#Preview {
    NewsView()
        .environmentObject(GameState())
}
