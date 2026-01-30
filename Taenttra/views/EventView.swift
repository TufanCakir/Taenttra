//
//  EventView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct EventView: View {

    @ObservedObject var viewModel: EventViewModel
    @EnvironmentObject var gameState: GameState

    let onStartEvent: (EventMode) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // ⬅️ GAME BACK BUTTON
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            // 📜 CONTENT
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.events) { event in
                        Button {
                            viewModel.select(event)
                            onStartEvent(event)
                        } label: {
                            EventRow(event: event)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 80)  // 🔥 Platz für BackButton + Title
                .padding(.bottom, 24)
            }
        }
    }
}
