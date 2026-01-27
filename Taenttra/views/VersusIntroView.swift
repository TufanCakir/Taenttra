//
//  VersusIntroView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct VersusIntroView: View {

    let stage: VersusStage
    let enemyName: String
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("VERSUS")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.red)

                VStack(spacing: 8) {
                    Text(stage.name.uppercased())
                        .font(.title2.weight(.semibold))

                    Text("VS")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(enemyName)
                        .font(.title3)
                        .foregroundStyle(.cyan)
                }

                Button {
                    onStart()
                } label: {
                    Text("START FIGHT")
                        .font(.headline.bold())
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .foregroundStyle(.black)
                        .cornerRadius(8)
                }
            }
        }
    }
}
