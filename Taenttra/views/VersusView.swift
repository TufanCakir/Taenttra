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
            VStack {  // Use VStack to allow placing fighters and overlays in ZStack orderly
                Spacer()
                HStack(alignment: .bottom) {

                    FighterContainerView(
                        alignment: .leading,
                        xInset: 30,
                        yInset: -100,  // ⬅️ NACH OBEN = weiter hinten
                        scale: 0.80,  // ⬅️ kleiner = Tiefe
                        content: FighterView(
                            character: leftCharacter,
                            state: viewModel.animationState,
                            rotation: 0,
                            mirrored: false,
                            attackOffset: viewModel.attackOffset
                        )
                    )

                    FighterContainerView(
                        alignment: .trailing,
                        xInset: -30,
                        yInset: -100,
                        scale: 0.80,  // ⬅️ kleiner = Tiefe
                        content: FighterView(
                            character: currentEnemy,
                            state: viewModel.animationState,
                            rotation: 0,
                            mirrored: true,
                            attackOffset: viewModel.attackOffset
                        )
                    )
                }
                .padding()
            }

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
        .offset(x: viewModel.hitShakeOffset)
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

        // 1️⃣ Story & Event Overrides
        switch gameState.pendingMode {

        case .story(_, let section):
            if section.boss == true {
                return "boss"
            }
            return contrastingSkin(from: playerSkinId)

        case .eventMode:
            return "event"

        default:
            break
        }

        // 2️⃣ Alle anderen Modi
        return contrastingSkin(from: playerSkinId)
    }

    private func contrastingSkin(from playerSkin: String) -> String {
        switch playerSkin {
        case "base", "":
            return "red"
        case "red":
            return "base"
        case "shadow":
            return "base"
        default:
            return "base"
        }
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

#Preview {
    let mockStage = VersusStage(
        id: "preview",
        name: "Preview Stage",
        background: "night",  // ⬅️ dein BG-Asset
        music: "preview",
        waves: [
            VersusWave(
                wave: 1,
                enemies: ["kenji"],
                timeLimit: 99
            )
        ]
    )

    let mockViewModel = VersusViewModel(stages: [mockStage])

    let gameState = GameState()
    gameState.pendingMode = .versus
    gameState.currentStage = mockStage

    return VersusView(
        viewModel: mockViewModel,
        onVictoryContinue: { _ in },
        leftCharacter: Character(
            key: "kenji",
            isLocked: false,
            skinId: "base"
        )
    )
    .environmentObject(gameState)
}
