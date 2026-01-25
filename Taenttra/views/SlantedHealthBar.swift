//
//  SlantedHealthBar.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//
import SwiftUI

struct SlantedHealthBar: View {

    let value: CGFloat
    let direction: SlantDirection

    private let width: CGFloat = 150
    private let height: CGFloat = 14
    private let cap: CGFloat = 18

    private var v: CGFloat { min(max(value, 0), 1) }

    var body: some View {
        ZStack {

            // 🔳 Base
            Rectangle()
                .fill(Color.black.opacity(0.35))
                .frame(width: width, height: height)
                .mask(capShape)

            // 🟥🟨🟩 Health Fill
            Rectangle()
                .fill(healthGradient)
                .frame(width: width, height: innerHeight)
                .scaleEffect(
                    x: v,
                    y: 1,
                    anchor: direction == .left ? .leading : .trailing
                )
                .mask(capShape)

            // ✨ Gloss
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height * 0.45)
                .mask(capShape)

            // 🧱 Outline
            capShape
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
                .frame(width: width, height: height)
        }
        .animation(.easeOut(duration: 0.25), value: v)
    }

    private var innerHeight: CGFloat { height - 4 }

    // MARK: - Mask (NICHT transformieren!)
    private var capShape: some Shape {
        Cap(
            mirrored: direction == .right,
            cap: cap
        )
    }

    // MARK: - Gradient (hier spiegeln!)
    private var healthGradient: LinearGradient {
        direction == .left
            ? LinearGradient(
                colors: [.green, .yellow, .red],
                startPoint: .leading,
                endPoint: .trailing
            )
            : LinearGradient(
                colors: [.green, .yellow, .red],
                startPoint: .trailing,
                endPoint: .leading
            )
    }
}

struct Cap: Shape {
    let mirrored: Bool
    let cap: CGFloat

    func path(in r: CGRect) -> Path {
        Path { p in
            if !mirrored {
                // rechte spitze Kappe (gespiegelt)
                p.move(to: CGPoint(x: r.minX, y: r.minY))
                p.addLine(to: CGPoint(x: r.maxX - cap, y: r.minY))
                p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
                p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
                p.closeSubpath()
            } else {
                // linke spitze Kappe
                p.move(to: CGPoint(x: cap, y: r.minY))
                p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
                p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
                p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            }
            p.closeSubpath()
        }
    }
}

#Preview {
    VStack(spacing: 24) {

        SlantedHealthBar(
            value: 1.0,
            direction: .left
        )

        SlantedHealthBar(
            value: 1.0,
            direction: .right
        )

        SlantedHealthBar(
            value: 1.0,
            direction: .left
        )

        SlantedHealthBar(
            value: 1.0,
            direction: .right
        )
    }
    .padding()
    .background(Color.black)
}
