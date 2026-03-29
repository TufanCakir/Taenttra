//
//  EventView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct EventView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let heroHeight: CGFloat = 212
    }

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
            backgroundLayer

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VersusHeaderView()

                    heroCard

                    if viewModel.modes.isEmpty {
                        emptyState
                    } else {
                        modeSelector
                        eventList
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            if selectedModeID == nil {
                selectedModeID = viewModel.modes.first?.id
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.08, green: 0.02, blue: 0.14),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -120, y: -230)

            Circle()
                .fill(activeAccentColor.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 48)
                .offset(x: 150, y: 160)

            if let selectedMode {
                Color(hex: selectedMode.ui.overlayColor)
                    .opacity(selectedMode.ui.overlayOpacity)
                    .ignoresSafeArea()
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 0.4), value: selectedMode.id)
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            activeAccentColor.opacity(0.4),
                            Color.white.opacity(0.08),
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
                .fill(activeAccentColor.opacity(0.22))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .offset(x: 132, y: -28)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    headerChip(title: "EVENT", color: activeAccentColor)
                    Spacer()
                    headerChip(title: selectedMode?.title.uppercased() ?? "ROTATION", color: .white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("EVENT HUB")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text(heroSubtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }
            }
            .padding(22)
        }
        .frame(height: Layout.heroHeight)
        .shadow(color: activeAccentColor.opacity(0.18), radius: 20)
    }

    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("EVENT CHANNELS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(activeAccentColor)

                Spacer()

                Circle()
                    .fill(activeAccentColor)
                    .frame(width: 8, height: 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.modes) { mode in
                        modeButton(mode)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(18)
        .background(sectionBackground(accent: activeAccentColor))
    }

    private var eventList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ACTIVE MISSIONS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.yellow)

                Spacer()

                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
            }

            if filteredEvents.isEmpty {
                VStack(spacing: 10) {
                    Text("NO EVENTS READY")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white)

                    Text("Switch channels or update your event data to load new missions.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 42)
            } else {
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
                .id(selectedModeID)
            }
        }
        .padding(18)
        .background(sectionBackground(accent: .yellow))
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
            Text(mode.title.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.3)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundColor(selectedModeID == mode.id ? .black : .white)
                .background(
                    Capsule()
                        .fill(
                            Color(hex: mode.ui.buttonColor)
                                .opacity(selectedModeID == mode.id ? 1.0 : 0.18)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    Color(hex: mode.ui.buttonColor).opacity(selectedModeID == mode.id ? 0 : 0.45),
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(selectedModeID == mode.id ? 1.06 : 1.0)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("NO EVENT MODES")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white)

            Text("Check your event data and try again.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(sectionBackground(accent: activeAccentColor))
    }

    private var activeAccentColor: Color {
        if let selectedMode {
            return Color(hex: selectedMode.ui.buttonColor)
        }

        return .cyan
    }

    private var heroSubtitle: String {
        if let selectedMode {
            return "Rotate into \(selectedMode.title.lowercased()) missions, defeat featured enemies, and claim time-based rewards."
        }

        return "Choose an event channel and launch limited battle missions."
    }

    private func headerChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func sectionBackground(accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(accent.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: accent.opacity(0.12), radius: 12)
    }
}
