//
//  FighterContainerView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct FighterContainerView: View {

    let alignment: Alignment
    let xInset: CGFloat
    let yInset: CGFloat
    let scale: CGFloat
    let content: FighterView

    var body: some View {
        ZStack(alignment: alignment) {
            content
                .scaleEffect(scale)
                .offset(x: xInset, y: yInset)
        }
    }
}
