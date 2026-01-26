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

    var body: some View {
        ZStack {

            // 🌄 BACKGROUND (ignoriert Safe Area)
            Image(viewModel.currentStage.background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            // 🆕 VERSUS INTRO OVERLAY
            if viewModel.phase == .intro {
                VersusIntroView(
                    stage: viewModel.currentStage,
                    enemyName: currentEnemy.key.uppercased()
                ) {
                    viewModel.startFight()
                }
                .zIndex(20)
            }
            
            // 🥊 FIGHTERS (unten, unabhängig vom HUD)
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    FighterContainerView(
                        alignment: .leading,
                        content: FighterView(
                            character: leftCharacter,
                            state: viewModel.animationState,
                            rotation: 12,
                            mirrored: false,
                            attackOffset: viewModel.attackOffset
                        )
                    )

                    FighterContainerView(
                        alignment: .trailing,
                        content: FighterView(
                            character: currentEnemy,
                            state: viewModel.animationState,
                            rotation: -12,
                            mirrored: true,
                            attackOffset: viewModel.attackOffset
                        )
                    )
                }
                .padding(.bottom, 24)
            }
            .offset(x: viewModel.hitShakeOffset)

            // 🏆 VICTORY OVERLAY
            if viewModel.fightState == .victory,
                let rewards = viewModel.rewards
            {

                VictoryView(rewards: rewards) {
                    onVictoryContinue(rewards)
                }
                .zIndex(10)
            }
        }
        // 🧠 HUD LEBT HIER – NICHT IM ZSTACK
        .safeAreaInset(edge: .top) {
            if viewModel.phase == .fighting {
                GameHUDView(viewModel: viewModel)
            }
        }
        .animation(.easeOut(duration: 0.3), value: viewModel.fightState)
        .animation(
            viewModel.hitStopActive ? .none : .easeOut(duration: 0.1),
            value: viewModel.hitStopActive
        )
        .contentShape(Rectangle())  // sauberes Tap-Handling
        .onTapGesture {
            if viewModel.fightState == .fighting {
                viewModel.performRandomAttack()
            }
        }
    }

    private var enemySkinId: String {

        // 1️⃣ HARTE OVERRIDES (Story / Event)
        switch gameState.pendingMode {

        case .story(_, let section):
            if section.boss == true {
                return "boss"
            }
            // Non-boss Story Enemy
            return playerSkinId == "base" ? "red" : "base"

        case .eventMode:
            return "event"

        default:
            break
        }

        // 2️⃣ VERSUS / ARCADE / TRAINING / SURVIVAL
        if playerSkinId == "base" || playerSkinId.isEmpty {
        }

        return "base"
    }

    
    private var playerSkinId: String {
        leftCharacter.skinId
    }

    // MARK: - Enemy (safe)
    private var currentEnemy: Character {
        let key = viewModel.currentWave?.enemies.first ?? "kenji"
        
        return Character(
            key: key,
            isLocked: false,
            skinId: enemySkinId
        )
    }
}
