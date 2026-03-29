//
//  EventView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct EventView: View {
    @ObservedObject var viewModel: EventViewModel
    @EnvironmentObject var gameState: GameState
    @State private var selectedModeID: String?

    let onStartEvent: (EventMode) -> Void

    init(
        viewModel: EventViewModel,
        onStartEvent: @escaping (EventMode) -> Void
    ) {
        self.viewModel = viewModel
        self.onStartEvent = onStartEvent
        _selectedModeID = State(initialValue: viewModel.modes.first?.id)
    }

    private var selectedMode: EventCategory? {
        if let selectedModeID,
            let matchingMode = viewModel.modes.first(where: { $0.id == selectedModeID })
        {
            return matchingMode
        }

        return viewModel.modes.first
    }

    private var filteredEvents: [EventMode] {
        guard let selectedMode else { return [] }
        return viewModel.events(for: selectedMode)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            if let selectedMode {
                Color(hex: selectedMode.ui.overlayColor)
                    .opacity(selectedMode.ui.overlayOpacity)
                    .ignoresSafeArea()
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 0.4), value: selectedMode.id)
            }

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            VStack(spacing: 24) {
                if viewModel.modes.isEmpty {
                    emptyState
                } else {
                    modeSelector
                    eventList
                }
            }
        }
        .onAppear {
            if selectedModeID == nil {
                selectedModeID = viewModel.modes.first?.id
            }
        }
    }

    private var modeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.modes) { mode in
                    modeButton(mode)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 72)
    }

    private var eventList: some View {
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
            .id(selectedModeID)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
        .animation(.easeInOut(duration: 0.35), value: selectedModeID)
    }

    @ViewBuilder
    private func modeButton(_ mode: EventCategory) -> some View {
        Button {
            guard selectedModeID != mode.id else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            withAnimation(.easeInOut(duration: 0.45)) {
                selectedModeID = mode.id
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
                                .opacity(selectedModeID == mode.id ? 1.0 : 0.25)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    Color(hex: mode.ui.buttonColor),
                                    lineWidth: selectedModeID == mode.id ? 0 : 1
                                )
                        )
                )
                .scaleEffect(selectedModeID == mode.id ? 1.08 : 1.0)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("No Event Modes Available")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Check your event data and try again.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.top, 72)
    }
}
