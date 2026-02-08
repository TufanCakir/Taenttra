//
//  EventBackgroundView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct EventBackgroundView: View {

    @EnvironmentObject var bgManager: BackgroundManager

    let background: EventBackground

    var body: some View {
        switch background {

        case .grid(_):

            SpiritGridBackground(style: bgManager.selected)

        case .image(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipped()
        }
    }
}
