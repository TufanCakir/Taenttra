//
//  FighterView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct FighterView: View {

    let character: Character
    let state: FighterAnimation
    let rotation: Double
    let mirrored: Bool
    let attackOffset: CGFloat

    var body: some View {
        Image(
            character.imageNameSafe(
                for: state.characterState  // ✅ HIER DER FIX
            )
        )
        .resizable()
        .scaledToFit()
        .frame(width: 180, height: 260)
        .offset(x: (mirrored ? -1 : 1) * attackOffset)
        .scaleEffect(x: mirrored ? 1 : -1, y: 1)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0),
            anchor: mirrored ? .leading : .trailing,
            perspective: 0.6
        )
    }
}
