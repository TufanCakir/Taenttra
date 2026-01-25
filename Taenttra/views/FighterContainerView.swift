//
//  FighterContainerView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import SwiftUI

struct FighterContainerView: View {

    let alignment: Alignment
    let content: FighterView

    var body: some View {
        ZStack(alignment: alignment) {
            content
        }
    }
}
