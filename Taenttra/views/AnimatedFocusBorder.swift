//
//  AnimatedFocusBorder.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

struct AnimatedFocusBorder: ViewModifier {

    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let isActive: Bool

    @Environment(\.colorScheme) private var colorScheme
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .stroke(borderColor, lineWidth: lineWidth)
                    .opacity(pulse ? 0.9 : 0.4)
                    .animation(
                        .easeInOut(duration: 1.4)
                            .repeatForever(autoreverses: true),
                        value: pulse
                    )
                    .onAppear { pulse = true }
                    .onDisappear { pulse = false }
                }
            }
    }

    private var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

extension View {
    func animatedFocusBorder(
        active: Bool,
        lineWidth: CGFloat = 2,
        radius: CGFloat = 14
    ) -> some View {
        modifier(
            AnimatedFocusBorder(
                lineWidth: lineWidth,
                cornerRadius: radius,
                isActive: active
            )
        )
    }
}
