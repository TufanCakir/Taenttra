//
//  VersusView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct VersusView: View {

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
            GameHUDView(viewModel: viewModel)
        }
        .animation(.easeOut(duration: 0.3), value: viewModel.fightState)
        .animation(viewModel.hitStopActive ? .none : .easeOut(duration: 0.1), value: viewModel.hitStopActive)
        .contentShape(Rectangle())  // sauberes Tap-Handling
        .onTapGesture {
            if viewModel.fightState == .fighting {
                viewModel.performRandomAttack()
            }
        }
    }

    // MARK: - Enemy (safe)
    private var currentEnemy: Character {
        let key = viewModel.currentWave?.enemies.first ?? "kenji"
        return Character(key: key, isLocked: false)
    }
}
