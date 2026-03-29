//
//  VersusView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct VersusView: View {

    private enum Layout {
        static let fighterScale: CGFloat = 0.8
        static let fighterYOffset: CGFloat = -100
        static let leftFighterXOffset: CGFloat = 30
        static let rightFighterXOffset: CGFloat = -30
    }

    @EnvironmentObject var gameState: GameState

    @ObservedObject var viewModel: VersusViewModel
    let onVictoryContinue: (VictoryRewards) -> Void
    let leftCharacter: Character
    let rightCharacter: Character

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

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    FighterContainerView(
                        alignment: .leading,
                        xInset: Layout.leftFighterXOffset,
                        yInset: Layout.fighterYOffset,
                        scale: Layout.fighterScale,
                        content: FighterView(
                            character: leftCharacter,
                            state: viewModel.leftAnimation,
                            rotation: 0,
                            mirrored: false,
                            attackOffset: viewModel.leftAttackOffset
                        )
                    )

                    FighterContainerView(
                        alignment: .trailing,
                        xInset: Layout.rightFighterXOffset,
                        yInset: Layout.fighterYOffset,
                        scale: Layout.fighterScale,
                        content: FighterView(
                            character: rightCharacter,
                            state: viewModel.rightAnimation,
                            rotation: 0,
                            mirrored: true,
                            attackOffset: viewModel.rightAttackOffset
                        )
                    )
                }
                .padding()
            }
        }
        .overlay(alignment: .center) {
            introOverlay
        }
        .overlay(alignment: .top) {
            hudOverlay
        }
        .animation(.easeOut(duration: 0.3), value: viewModel.fightState)
        .animation(
            viewModel.hitStopActive ? .none : .easeOut(duration: 0.1),
            value: viewModel.hitStopActive
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.phase == .fighting, viewModel.fightState == .fighting {
                viewModel.performRandomAttack()
            }
        }
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
