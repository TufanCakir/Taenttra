//
//  TeamSlotView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct TeamSlotView: View {

    let slot: TeamSlot
    let character: Character?
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            ZStack {

                Image("frame_slot")
                    .resizable()
                    .scaledToFit()

                HStack(spacing: 12) {

                    ZStack {
                        if let character = character {
                            Image(character.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        } else {
                            Image("slot_empty")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .opacity(0.4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {

                        Text(character?.name ?? "Empty Slot")
                            .foregroundColor(.white)
                            .font(.headline)

                        Text(character != nil ? "Tap to manage" : "Tap to assign")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 90)
    }
}
