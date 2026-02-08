//
//  ExampleChipsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

struct ExampleChipsView: View {
    let prompts: [ExamplePrompt]
    let isImageMode: Bool
    let onSelect: (String) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 10)
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(prompts) { prompt in
                    Button {
                        onSelect(prompt.text)
                    } label: {
                        chipLabel(prompt)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .frame(maxHeight: isImageMode ? 120 : 140)  // 👈 wichtig!
    }

    // MARK: - Chip Label
    private func chipLabel(_ prompt: ExamplePrompt) -> some View {
        HStack(spacing: 8) {
            if isImageMode {
                Image(systemName: "paintpalette.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text(prompt.text)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .font(isImageMode ? .callout : .footnote)
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .frame(height: isImageMode ? 40 : 34)
        .background(backgroundStyle)
        .overlay(borderOverlay)
        .clipShape(Capsule())
        .contentShape(Capsule())
    }

    // MARK: - Styles
    private var backgroundStyle: some ShapeStyle {
        isImageMode
            ? AnyShapeStyle(.ultraThinMaterial)
            : AnyShapeStyle(.thinMaterial)
    }

    private var borderOverlay: some View {
        Capsule()
            .strokeBorder(
                .white.opacity(isImageMode ? 0.18 : 0.10),
                lineWidth: 1
            )
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct PressEffect: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1)
            .opacity(isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

extension View {
    fileprivate func pressEffect() -> some View {
        modifier(PressEffect())
    }
}
