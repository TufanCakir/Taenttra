//
//  WaveIntroView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 29.01.26.
//

import SwiftUI

struct WaveIntroView: View {

    let wave: Int
    let enemyKey: String
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("WAVE \(wave)")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)

                Image("\(enemyKey)_base_preview")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)

                Text(enemyKey.uppercased())
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .onTapGesture {
            onContinue()
        }
    }
}
