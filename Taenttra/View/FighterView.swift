//
//  FighterView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct FighterView: View {
    private enum Layout {
        static let width: CGFloat = 180
        static let height: CGFloat = 280
    }

    let character: Character
    let state: FighterAnimation
    let rotation: Double
    let mirrored: Bool
    let attackOffset: CGFloat

    var body: some View {
        Image(
            character.spriteName(
                for: state.characterState
            )
        )
        .resizable()
        .scaledToFit()
        .frame(width: Layout.width, height: Layout.height)
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
