//
//  SlantedPlayerHUD.swift
//  Taenttra
//
//  Created by Tufan Cakir on 23.01.26.
//

import SwiftUI

struct SlantedPlayerHUD: View {

    let name: String
    let health: CGFloat
    let direction: SlantDirection

    var body: some View {
        VStack(
            alignment: direction == .left ? .leading : .trailing,
            spacing: 4
        ) {
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .textCase(nil)  // ❗️stellt sicher, dass SwiftUI nix umwandelt

            SlantedHealthBar(
                value: health,
                direction: direction
            )
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SlantedPlayerHUD(name: "Kenji", health: 1.0, direction: .left)
        SlantedPlayerHUD(name: "Ryu", health: 0.35, direction: .right)
    }
    .padding()
}
