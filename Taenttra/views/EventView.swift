//
//  EventView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct EventView: View {

    @EnvironmentObject var bgManager: BackgroundManager

    @EnvironmentObject private var game: SpiritGameController

    @State private var events: [GameEvent] = []
    @State private var selectedEvent: GameEvent?
    @State private var showBattle: Bool = false

    @State private var selectedCategory: EventCategory? = nil  // nil = ALL

    init() {
        _events = State(initialValue: EventLoader.loadEvents())
    }

    // 🔥 Kategorien für Leiste
    private var categories: [EventCategory] {
        EventCategory.allCases
    }

    // 🔥 Gefilterte Events
    private var filteredEvents: [GameEvent] {
        let active = events.filter { $0.isActive }

        if let cat = selectedCategory {
            return active.filter { $0.category == cat }
        }
        return active
    }

    var body: some View {
        ZStack {
            SpiritGridBackground(style: bgManager.selected)

            VStack(spacing: 22) {

                // 🔥 CATEGORY BAR
                categoryBar

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredEvents) { event in
                            eventCard(event)
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, showBattle: $showBattle)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showBattle) {
            EventGameView()
                .environmentObject(game)
        }
    }
}

extension EventView {

    fileprivate func eventCard(_ event: GameEvent) -> some View {
        ZStack(alignment: .bottomLeading) {

            // 🎨 BACKGROUND
            EventBackgroundView(background: event.background)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()

            // 🌫️ Gradient für Lesbarkeit
            LinearGradient(
                colors: [.black.opacity(0.75), .clear],
                startPoint: .bottom,
                endPoint: .center
            )

            // 📝 TITLE + TIMER
            VStack(alignment: .leading, spacing: 6) {
                Text(event.name)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)

                if event.isActive {
                    Text("⏳ \(event.remainingDays) days left")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
            .padding(16)
        }
    }
}

extension EventView {

    fileprivate var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {

                // ALL Button
                categoryButton(
                    title: "All",
                    isActive: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                // Dynamisch Kategorien erzeugen
                ForEach(categories, id: \.self) { cat in
                    categoryButton(
                        title: cat.rawValue.capitalized,
                        isActive: selectedCategory == cat
                    ) {
                        selectedCategory = cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }

    // UI für einzelne Kategorie-Buttons
    fileprivate func categoryButton(
        title: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(
                        isActive
                            ? Color.blue.opacity(0.8)
                            : Color.white.opacity(0.15)
                    )
                )
                .overlay(
                    Capsule().stroke(
                        isActive ? Color.white : Color.white.opacity(0.3),
                        lineWidth: 1
                    )
                )
                .shadow(
                    color: isActive ? .blue.opacity(0.6) : .clear,
                    radius: 8
                )
        }
    }
}

struct EventDetailView: View {
    let event: GameEvent
    @Binding var showBattle: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: SpiritGameController

    var body: some View {
        VStack(spacing: 16) {
            Text(event.description)
                .font(Font.body.italic())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                .opacity(event.isActive ? 1.0 : 0.35)
                .overlay {
                    if !event.isActive {
                        Text("Coming Soon")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.black.opacity(0.6))
                            .clipShape(Capsule())
                    }
                }

            Spacer()

            Button(action: {
                game.startEvent(event)
                dismiss()
                showBattle = true
            }) {
                Text("Start Battle")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .clipShape(Capsule())
            }

            .padding(.bottom, 20)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black, .blue, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    EventView()
        .environmentObject(SpiritGameController())
}
