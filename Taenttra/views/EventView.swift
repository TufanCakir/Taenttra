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
    @State private var currentType: EventType = .normal
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

    var filteredEvents: [EventMode] {
        viewModel.events(for: selectedMode)
    }

    var activeOverlay: EventUIConfig? {
        filteredEvents.first?.ui
    }

    var modeSwitchButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.45)) {
                currentType = currentType == .normal ? .special : .normal
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            Text(currentType == .normal ? "SPEZIAL EVENTS" : "NORMALE EVENTS")
                .font(.headline.weight(.bold))
                .padding()
                .background(
                    Capsule()
                        .fill(
                            currentType == .normal ? Color.purple : Color.green
                        )
                )
                .foregroundColor(.black)
        }
    }

    var fallbackOverlay: EventUIConfig {
        EventUIConfig(
            overlayColor: "#FFFFFF",
            overlayOpacity: 0.1
        )
    }

    var ui: EventUIConfig { activeOverlay ?? fallbackOverlay }

    var body: some View {
        ZStack(alignment: .topLeading) {

            // 🌑 BASE (GANZ UNTEN)
            Color.black
                .ignoresSafeArea()

            // 🎨 OVERLAY (DARÜBER)
            Color(hex: selectedMode.ui.overlayColor)
                .opacity(selectedMode.ui.overlayOpacity)
                .ignoresSafeArea()
                .blendMode(.screen)
                .animation(.easeInOut(duration: 0.4), value: selectedMode.id)

            // ⬅️ BACK BUTTON
            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            VStack(spacing: 12) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.modes) { mode in
                            Button {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    selectedMode = mode
                                }
                                UIImpactFeedbackGenerator(style: .medium)
                                    .impactOccurred()
                            } label: {
                                Text(mode.title)
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                Color(hex: mode.ui.buttonColor)
                                            )
                                    )
                                    .foregroundColor(.black)
                                    .opacity(
                                        selectedMode.id == mode.id ? 1 : 0.5
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 60)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(filteredEvents) { event in
                            Button {
                                onStartEvent(event)
                            } label: {
                                EventRow(event: event)
                                    .transition(
                                        .asymmetric(
                                            insertion: .opacity.combined(
                                                with: .scale(scale: 1.05)
                                            ),
                                            removal: .opacity.combined(
                                                with: .scale(scale: 0.95)
                                            )
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
