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
    @State private var selectedMode: EventCategory

    init(
        viewModel: EventViewModel,
        onStartEvent: @escaping (EventMode) -> Void
    ) {
        self.viewModel = viewModel
        self.onStartEvent = onStartEvent
        _selectedMode = State(initialValue: viewModel.modes.first!)
    }

    let onStartEvent: (EventMode) -> Void

    private var filteredEvents: [EventMode] {
        viewModel.events(for: selectedMode)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE
            Color.black.ignoresSafeArea()

            // 🎨 MODE OVERLAY
            Color(hex: selectedMode.ui.overlayColor)
                .opacity(selectedMode.ui.overlayOpacity)
                .ignoresSafeArea()
                .blendMode(.screen)
                .animation(.easeInOut(duration: 0.4), value: selectedMode.id)

            // ⬅️ BACK
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            VStack(spacing: 24) {

                // 🧭 MODE SELECTOR
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.modes) { mode in
                            modeButton(mode)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 72)

                // 📜 EVENTS
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredEvents) { event in
                            Button {
                                onStartEvent(event)
                            } label: {
                                EventRow(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                    .id(selectedMode.id)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
                .animation(.easeInOut(duration: 0.35), value: selectedMode.id)
            }
        }
    }

    // MARK: - Mode Button
    @ViewBuilder
    private func modeButton(_ mode: EventCategory) -> some View {
        Button {
            guard selectedMode.id != mode.id else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            withAnimation(.easeInOut(duration: 0.45)) {
                selectedMode = mode
            }
        } label: {
            Text(mode.title)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .foregroundColor(.black)
                .background(
                    Capsule()
                        .fill(
                            Color(hex: mode.ui.buttonColor)
                                .opacity(
                                    selectedMode.id == mode.id ? 1.0 : 0.25
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    Color(hex: mode.ui.buttonColor),
                                    lineWidth: selectedMode.id == mode.id
                                        ? 0 : 1
                                )
                        )
                )
                .scaleEffect(selectedMode.id == mode.id ? 1.08 : 1.0)
        }
    }
}
