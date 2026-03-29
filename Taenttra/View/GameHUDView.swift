//
//  GameHUDView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct GameHUDView: View {

    private enum Layout {
        static let backplateHeight: CGFloat = 96
        static let timerFontSize: CGFloat = 22
        static let timerHorizontalPadding: CGFloat = 14
        static let timerVerticalPadding: CGFloat = 6
        static let timerShadowRadius: CGFloat = 8
    }

    @ObservedObject var viewModel: VersusViewModel
    @EnvironmentObject var gameState: GameState

    private var isLowTime: Bool {
        viewModel.timeRemaining <= 10
    }

    var body: some View {
        hudBar
    }

    private var hudBar: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.65),
                    Color.clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Layout.backplateHeight)

            HStack {
                SlantedPlayerHUD(
                    name: displayName(for: gameState.leftCharacter),
                    health: viewModel.leftHealth,
                    direction: .left
                )

                Spacer()

                timerView

                Spacer()

                SlantedPlayerHUD(
                    name: displayName(for: gameState.rightCharacter),
                    health: viewModel.rightHealth,
                    direction: .right
                )
            }
        }
    }

    private var timerView: some View {
        Text("\(viewModel.timeRemaining)")
            .font(.system(size: Layout.timerFontSize, weight: .heavy, design: .monospaced))
            .foregroundStyle(isLowTime ? .red : .white)
            .padding(.horizontal, Layout.timerHorizontalPadding)
            .padding(.vertical, Layout.timerVerticalPadding)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        Capsule()
                            .stroke(
                                isLowTime ? Color.red.opacity(0.8) : Color.white.opacity(0.25),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: isLowTime ? Color.red.opacity(0.7) : .black.opacity(0.6),
                radius: Layout.timerShadowRadius
            )
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.timeRemaining
            )
    }

    private func displayName(for character: Character?) -> String {
        guard let key = character?.key else { return "" }

        return gameState.characterDisplays
            .first(where: { $0.key == key })?
            .name
            ?? key.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
