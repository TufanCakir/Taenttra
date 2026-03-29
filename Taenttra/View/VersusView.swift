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
}
