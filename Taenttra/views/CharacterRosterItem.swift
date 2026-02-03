//
//  CharacterRosterItem.swift
//  Taenttra
//
//  Created by Tufan Cakir on 03.02.26.
//

import SwiftUI

struct CharacterRosterItem: View {
    let image: String
    let isSelected: Bool
    let locked: Bool
    let action: () -> Void

    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: isSelected ? 68 : 56, height: isSelected ? 68 : 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.cyan : .clear, lineWidth: 3)
            )
            .opacity(locked ? 0.3 : 1)
            .onTapGesture {
                guard !locked else { return }
                action()
            }
    }
}
