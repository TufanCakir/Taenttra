//
//  GameHUDView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftUI

struct GameHUDView: View {

    @ObservedObject var viewModel: VersusViewModel

    var body: some View {
        VStack {
            ZStack {

                HStack {
                    SlantedPlayerHUD(
                        name: viewModel.currentStage.name,
                        health: viewModel.leftHealth,
                        direction: .left
                    )

                    Spacer()

                    SlantedPlayerHUD(
                        name: viewModel.currentWave?.enemies.first?.uppercased()
                            ?? "",
                        health: viewModel.rightHealth,
                        direction: .right
                    )
                }

                Text("\(viewModel.timeRemaining)")
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(viewModel.timeRemaining <= 10 ? .red : .white)
            }
            .padding()

            Spacer()
        }
    }
}
