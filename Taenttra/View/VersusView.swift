//
//  VersusView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct VersusView: View {

    private enum Layout {
        static let boardCornerRadius: CGFloat = 34
        static let boardSidePadding: CGFloat = 18
    }

    @EnvironmentObject var gameState: GameState
    @State private var transformationFlash = false
    @State private var transformationBurst = false
    @State private var transformationFlip = false

    @ObservedObject var viewModel: VersusViewModel
    let onVictoryContinue: (VictoryRewards) -> Void
    let leftCharacter: Character
    let rightCharacter: Character

    private var playerHealth: CGFloat {
        gameState.playerSide == .left ? viewModel.leftHealth : viewModel.rightHealth
    }

    private var enemyHealth: CGFloat {
        gameState.playerSide == .left ? viewModel.rightHealth : viewModel.leftHealth
    }

    var body: some View {
        ZStack {
            switch viewModel.fightState {
            case .fighting:
                fightView
                    .transition(.opacity)
            case .ko:
                if let winner = viewModel.winner {
                    KOView(winnerSide: winner) {
                        gameState.exitVersusAfterKO()
                    }
                    .zIndex(50)
                }
            case .victory:
                if let rewards = viewModel.rewards {
                    VictoryView(rewards: rewards) {
                        onVictoryContinue(rewards)
                    }
                    .zIndex(100)
                }
            case .timeout:
                fightView
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.fightState)
        .onChange(of: viewModel.transformationShowcase?.id) { _, _ in
            guard viewModel.transformationShowcase != nil else { return }
            transformationFlash = false
            transformationBurst = false
            transformationFlip = false

            withAnimation(.easeOut(duration: 0.18)) {
                transformationFlash = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                transformationBurst = true
            }
            withAnimation(.easeInOut(duration: 0.56).delay(0.08)) {
                transformationFlip = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
                withAnimation(.easeOut(duration: 0.5)) {
                    transformationFlash = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.35)) {
                    transformationBurst = false
                }
            }
        }
    }

    private var fightView: some View {
        ZStack {
            Image(viewModel.currentStage.background)
                .resizable()
                .ignoresSafeArea()

            Color.black.opacity(0.28)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                enemyDeck
                boardCenter
                playerDeck
                tapHint
            }
            .padding(.horizontal, Layout.boardSidePadding)
            .padding(.top, 104)
            .padding(.bottom, 32)
        }
        .overlay(alignment: .center) {
            introOverlay
        }
        .overlay {
            transformationOverlay
        }
        .overlay(alignment: .top) {
            hudOverlay
        }
    }

    private var enemyDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ENEMY FIELD")
                    .font(.system(size: 13, weight: .black))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text("WAVE \(viewModel.currentWaveIndex + 1)")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.4)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.55), in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.enemyCards) { card in
                        BattleCardView(
                            card: card,
                            isSelected: false,
                            isHighlighted: viewModel.highlightedEnemyCardID == card.id,
                            isDisabled: true,
                            action: nil
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var boardCenter: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Layout.boardCornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.boardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(spacing: 14) {
                Text("CARD BATTLE GRID")
                    .font(.system(size: 22, weight: .black))
                    .tracking(2.2)
                    .foregroundStyle(.white)

                Text(viewModel.lastActionText)
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(1.6)
                    .foregroundStyle(.cyan.opacity(0.95))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08), in: Capsule())

                HStack(spacing: 14) {
                    statPanel(
                        title: "PLAYER HP",
                        value: "\(Int(playerHealth * 100))%",
                        tint: .cyan
                    )
                    statPanel(
                        title: "ENEMY HP",
                        value: "\(Int(enemyHealth * 100))%",
                        tint: .orange
                    )
                }

                HStack(spacing: 14) {
                    energyPanel(
                        title: "PLAYER KI",
                        energy: viewModel.playerEnergy,
                        deckCount: viewModel.playerDeckCount,
                        tint: .cyan
                    )
                    energyPanel(
                        title: "ENEMY KI",
                        energy: viewModel.enemyEnergy,
                        deckCount: viewModel.enemyDeckCount,
                        tint: .orange
                    )
                }

                HStack(spacing: 14) {
                    statusPanel(
                        title: "PLAYER STATUS",
                        primary: viewModel.playerStatusText,
                        secondary: "Shield \(Int((viewModel.playerShield * 100).rounded()))  •  Boost \(viewModel.playerBoostStacks)",
                        tint: .cyan
                    )
                    statusPanel(
                        title: "ENEMY STATUS",
                        primary: viewModel.enemyStatusText,
                        secondary: "Shield \(Int((viewModel.enemyShield * 100).rounded()))  •  Boost \(viewModel.enemyBoostStacks)",
                        tint: .orange
                    )
                }

                laneGuide
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .offset(x: viewModel.hitShakeOffset)
    }

    private var laneGuide: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .overlay {
                        VStack(spacing: 8) {
                            Text("LANE \(index + 1)")
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(.white.opacity(0.7))

                            Circle()
                                .fill(index == 1 ? Color.purple.opacity(0.9) : Color.white.opacity(0.15))
                                .frame(width: 16, height: 16)
                        }
                    }
            }
        }
        .frame(height: 58)
    }

    private func statPanel(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.64))

            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Capsule()
                .fill(Color.white.opacity(0.12))
                .frame(width: 110, height: 8)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.95), tint.opacity(0.45)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 110 * (title == "PLAYER HP" ? playerHealth : enemyHealth), height: 8)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func energyPanel(title: String, energy: Int, deckCount: Int, tint: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.64))

                HStack(spacing: 5) {
                    ForEach(0..<viewModel.maxEnergy, id: \.self) { index in
                        Circle()
                            .fill(index < energy ? tint : Color.white.opacity(0.12))
                            .frame(width: 10, height: 10)
                    }
                }
            }

            Spacer()

            Text("DECK \(deckCount)")
                .font(.system(size: 11, weight: .black))
                .tracking(1.1)
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statusPanel(title: String, primary: String, secondary: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.64))

            Text(primary)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)

            Text(secondary)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var playerDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PLAYER FIELD")
                    .font(.system(size: 13, weight: .black))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text("TAP CARD TO ATTACK")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.4)
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.55), in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.playerCards) { card in
                        BattleCardView(
                            card: card,
                            isSelected: viewModel.selectedPlayerCardID == card.id,
                            isHighlighted: viewModel.highlightedPlayerCardID == card.id,
                            isDisabled: viewModel.phase != .fighting || viewModel.fightState != .fighting,
                            action: {
                                viewModel.selectPlayerCard(card.id)
                                viewModel.performCardAttack(with: card)
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var tapHint: some View {
        Text("KAMPF LAUFT JETZT ALS KARTEN-DUELL")
            .font(.system(size: 11, weight: .black))
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.72))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.55), in: Capsule())
    }

    @ViewBuilder
    private var introOverlay: some View {
        if viewModel.phase == .intro {
            VersusIntroView(
                stage: viewModel.currentStage,
                enemyName: rightCharacter.key.uppercased()
            ) {
                viewModel.startFight()
            }
            .zIndex(20)
        }
    }

    @ViewBuilder
    private var hudOverlay: some View {
        if viewModel.phase == .fighting {
            GameHUDView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var transformationOverlay: some View {
        if let showcase = viewModel.transformationShowcase {
            ZStack {
                Color.black.opacity(0.34)
                    .ignoresSafeArea()

                transformationFXLayer(for: showcase)

                VStack(spacing: 14) {
                    Text(showcase.side == gameState.playerSide ? "PLAYER AWAKENING" : "ENEMY AWAKENING")
                        .font(.system(size: 12, weight: .black))
                        .tracking(2)
                        .foregroundStyle(.yellow)

                    ZStack(alignment: .bottomLeading) {
                        transformationCardFace(showcase: showcase)
                            .opacity(transformationFlip ? 0 : 1)
                            .rotation3DEffect(.degrees(transformationFlip ? -90 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.72)

                        awakenedCardFace(showcase: showcase)
                            .opacity(transformationFlip ? 1 : 0)
                            .rotation3DEffect(.degrees(transformationFlip ? 0 : 90), axis: (x: 0, y: 1, z: 0), perspective: 0.72)
                    }

                    Text("TRANSFORM SHIFT")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(.white)
                }
                .padding(26)
                .background(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(Color.black.opacity(0.62))
                        .overlay(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .scaleEffect(1.02)
                .transition(.asymmetric(insertion: .scale(scale: 0.88).combined(with: .opacity), removal: .opacity))
            }
            .zIndex(40)
        }
    }

    private func transformationFXLayer(for showcase: VersusViewModel.TransformationShowcase) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    .white.opacity(transformationFlash ? 0.9 : 0),
                    showcase.accentColor.opacity(transformationFlash ? 0.42 : 0),
                    .clear
                ],
                center: .center,
                startRadius: 8,
                endRadius: transformationFlash ? 260 : 120
            )
            .blendMode(.screen)
            .ignoresSafeArea()

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.8), showcase.accentColor, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 5
                )
                .frame(width: transformationBurst ? 360 : 180, height: transformationBurst ? 360 : 180)
                .blur(radius: transformationBurst ? 0 : 1.5)
                .opacity(transformationBurst ? 0 : 0.95)

            Circle()
                .stroke(showcase.frameColor.opacity(0.85), lineWidth: 2)
                .frame(width: transformationBurst ? 440 : 220, height: transformationBurst ? 440 : 220)
                .opacity(transformationBurst ? 0 : 0.75)

            ForEach(0..<14, id: \.self) { index in
                let angle = Double(index) / 14.0 * .pi * 2
                let startRadius: CGFloat = 36
                let endRadius: CGFloat = transformationBurst ? 210 : 74
                let x = cos(angle) * endRadius
                let y = sin(angle) * endRadius

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(index.isMultiple(of: 2) ? showcase.accentColor : .yellow)
                    .frame(width: 8, height: 28)
                    .rotationEffect(.radians(angle))
                    .offset(
                        x: transformationBurst ? x : cos(angle) * startRadius,
                        y: transformationBurst ? y : sin(angle) * startRadius
                    )
                    .opacity(transformationBurst ? 0 : 0.95)
                    .blur(radius: transformationBurst ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
    }

    private func transformationCardFace(showcase: VersusViewModel.TransformationShowcase) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            showcase.frameColor.opacity(0.82),
                            showcase.accentColor.opacity(0.38),
                            Color.black.opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 248, height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.7), showcase.frameColor, .yellow.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: showcase.frameColor.opacity(0.4), radius: 22)

            Circle()
                .fill(showcase.accentColor.opacity(0.22))
                .frame(width: 132, height: 132)
                .blur(radius: 10)

            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .frame(width: 114, height: 114)

            Circle()
                .stroke(showcase.accentColor.opacity(0.9), lineWidth: 5)
                .frame(width: 92, height: 92)

            VStack(spacing: 8) {
                Text("SYNC CORE")
                    .font(.system(size: 14, weight: .black))
                    .tracking(2.1)
                    .foregroundStyle(.white)
                Text("AWAKENING")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.yellow)
            }
        }
    }

    private func awakenedCardFace(showcase: VersusViewModel.TransformationShowcase) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            showcase.accentColor.opacity(0.25),
                            showcase.frameColor.opacity(0.55),
                            Color.black.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 248, height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.yellow, showcase.accentColor, .white.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: showcase.accentColor.opacity(0.45), radius: 26)

            Circle()
                .fill(showcase.accentColor.opacity(0.24))
                .frame(width: 180, height: 180)
                .blur(radius: 14)
                .offset(x: 18, y: -12)

            Image(showcase.artworkName)
                .resizable()
                .scaledToFit()
                .frame(width: 214, height: 250)
                .offset(y: -10)

            VStack(alignment: .leading, spacing: 4) {
                Text(showcase.title.uppercased())
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(showcase.subtitle.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.72))
                Text("AWAKENED \(showcase.rarity.displayTitle)")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(.yellow)
            }
            .padding(18)
        }
    }
}
