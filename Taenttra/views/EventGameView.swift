//
//  EventGameView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct EventGameView: View {

    @EnvironmentObject var bgManager: BackgroundManager
    @EnvironmentObject private var game: SpiritGameController
    @Environment(\.dismiss) private var dismiss

    @State private var activeSheet: ActiveSheet?
    @StateObject private var pulse = PulseManager()

    enum ActiveSheet: Identifiable {
        case upgrade, artefacts
        var id: String { "\(self)" }
    }

    var body: some View {
        ZStack {

            // ---------------------------------------------------
            // 🔥 1. RENDER (nur 3D Ansicht)
            // ---------------------------------------------------
            renderLayer

            // ---------------------------------------------------
            // 🔥 2. TAP ATTACK
            // ---------------------------------------------------
            attackLayer

            // 🔥 RAID OVERLAY (NUR ANZEIGE)
            if game.activeEvent?.category == .raid {
                VStack {
                    RaidOverlayView()
                    Spacer()
                }
                .zIndex(10)
                .transition(.move(edge: .top))
            }

            // ---------------------------------------------------
            // 🔥 3. HUD (Top + Bottom)
            // ---------------------------------------------------
            hudLayer
            
            // ⚡ FLOATING AUTO PLAY BUTTON (RECHTS MITTE)
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        game.toggleAutoBattle()
                    } label: {
                        Image(systemName: game.isAutoBattle ? "bolt.fill" : "bolt")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(
                                Circle().fill(
                                    game.isAutoBattle
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.black.opacity(0.6), Color.black.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                )
                            )
                            .overlay(
                                Circle().stroke(Color.cyan.opacity(0.8), lineWidth: 2)
                            )
                            .shadow(color: .cyan.opacity(0.8), radius: 12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 300)
                }
                
                Spacer()
            }
            .zIndex(20)

        }

        // → Event abgeschlossen → zurück
        .onChange(of: game.eventWon) { _, won in
            if won {
                dismiss()
                game.eventWon = false
            }
        }

        // Bottom Sheets
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .upgrade:
                UpgradeView()
                    .presentationDetents([.medium, .large])
            case .artefacts:
                ArtefactView()
            }
        }
    }
}

// MARK: - RENDER

extension EventGameView {
    fileprivate var renderLayer: some View {
        ZStack {

            if let bg = game.currentEventBackground {
                EventBackgroundView(background: bg)
            } else {

                SpiritGridBackground(style: bgManager.selected)
            }

            SpiritView(config: game.current)
                .id(game.current.id + "_event")

            PulseLayer(pulses: pulse.pulses)
        }
        .ignoresSafeArea()
    }
}

// MARK: - TAP

extension EventGameView {
    fileprivate var attackLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Pulse Effekt
                        pulse.spawnPulse(at: value.location)

                        // Attack während Drag
                        game.tapAttack()
                    }
                    .onEnded { value in
                        pulse.spawnPulse(at: value.location)
                    }
            )
            // Tap funktioniert auch weiterhin
            .simultaneousGesture(
                TapGesture().onEnded {
                    game.tapAttack()
                }
            )
            .ignoresSafeArea()
    }
}

// MARK: - HUD

extension EventGameView {
    fileprivate var hudLayer: some View {
        VStack {
            topHUD
            Spacer()
            bottomHUD
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    fileprivate var topHUD: some View {
        VStack(spacing: 14) {

         
            
            // HP-Bar (nur wenn KEIN Raid)
            if game.activeEvent?.category != .raid {
                normalHPBar
            }
        }
    }
    
    private var normalHPBar: some View {
        let maxHP = max(game.current.hp, 1)
        let percent = CGFloat(game.currentHP) / CGFloat(maxHP)

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.1))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 260 * percent)
                .animation(.easeInOut(duration: 0.3), value: game.currentHP)

            Text("\(game.currentHP) / \(maxHP)")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .heavy))
                .frame(maxWidth: .infinity)
        }
        .frame(width: 265, height: 26)
        .clipShape(Capsule())
    }


    fileprivate var bottomHUD: some View {
        HStack(spacing: 26) {

            // Upgrade
            footerButton(
                icon: "arrow.up.circle.fill",
                title: "Upgrade"
            ) {
                activeSheet = .upgrade
            }

            // Artefakte
            footerButton(
                icon: "sparkles",
                title: "Artefakte"
            ) {
                activeSheet = .artefacts
            }
        }
        .padding(.bottom, 40)
    }


    @ViewBuilder
    fileprivate func footerButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.headline)
                Text(title).font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
        }
    }
}

// MARK: - Button Model

private struct EventGameButton: Identifiable {
    let id = UUID()
    let type: String
    let icon: String
    let title: String
}

private let eventButtons: [EventGameButton] = [
    EventGameButton(type: "auto_battle", icon: "bolt.fill", title: "Auto")
]

// MARK: - Preview

#Preview {
    EventGameView()
        .environmentObject(SpiritGameController())
}

