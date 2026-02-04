//
//  VersusView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct VersusView: View {

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
                // optional: eigenes TimeoutView
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.fightState)
        .onAppear {
            print("🟢 VersusView APPEAR fightState =", viewModel.fightState)
        }
        .onDisappear {
            print("🔴 VersusView DISAPPEAR")
        }
    }

    private var fightView: some View {
        ZStack {
            // 🌄 BACKGROUND
            Image(viewModel.currentStage.background)
                .resizable()
                .ignoresSafeArea()

            // 🆕 INTRO
            if viewModel.phase == .intro {
                VersusIntroView(
                    stage: viewModel.currentStage,
                    enemyName: rightCharacter.key.uppercased()
                ) {
                    viewModel.startFight()
                }
                .zIndex(20)
            }

            // 🥊 FIGHTERS
            VStack {
                Spacer()
                HStack(alignment: .bottom) {

                    FighterContainerView(
                        alignment: .leading,
                        xInset: 30,
                        yInset: -100,
                        scale: 0.80,
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
                        xInset: -30,
                        yInset: -100,
                        scale: 0.80,
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
        // 🧠 HUD NUR IM FIGHT
        .overlay {
            if viewModel.phase == .fighting {
                GameHUDView(viewModel: viewModel)
            }
        }
        .animation(.easeOut(duration: 0.3), value: viewModel.fightState)
        .animation(
            viewModel.hitStopActive ? .none : .easeOut(duration: 0.1),
            value: viewModel.hitStopActive
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.fightState == .fighting {
                viewModel.performRandomAttack()
            }
        }
    }

    private var playerOnLeft: Bool {
        gameState.playerSide == .left
    }

    private var enemySkinId: String? {
        switch gameState.pendingMode {
        case .story(_, let section):
            if section.boss == true {
                return "boss"
            }
            return contrastingSkin(from: playerSkinId)
        case .eventMode:
            return "event"
        default:
            return contrastingSkin(from: playerSkinId)
        }
    }

    private func contrastingSkin(from playerSkin: String) -> String {
        switch playerSkin {
        case "base", "":
            return "red"
        case "red":
            return "base"
        case "modern":
            return "base"
        default:
            return "base"
        }
    }

    private var playerSkinId: String {
        playerOnLeft
            ? leftCharacter.skinId ?? "base"
            : rightCharacter.skinId ?? "base"
    }
}

