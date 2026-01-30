//
//  GameBackButton.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct GameBackButton: View {

    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {

                // 🌑 Background Capsule
                Capsule()
                    .fill(Color.black.opacity(0.75))
                    .frame(width: 44, height: 36)
                    .overlay(
                        Capsule()
                            .stroke(Color.cyan.opacity(0.6), lineWidth: 1)
                    )

                // ⬅️ Icon
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.white)
            }
            .shadow(
                color: Color.cyan.opacity(pressed ? 0.8 : 0.4),
                radius: pressed ? 12 : 6
            )
            .scaleEffect(pressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            pressed = true
        } onRelease: {
            pressed = false
        }
    }
}

extension View {
    func pressEvents(
        onPress: @escaping () -> Void,
        onRelease: @escaping () -> Void
    ) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}
