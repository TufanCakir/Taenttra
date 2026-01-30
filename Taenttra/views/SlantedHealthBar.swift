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
    private let height: CGFloat = 26
    private let cap: CGFloat = 18

    @State private var damageFlash = false
    @State private var lowPulse = false

    private var v: CGFloat { min(max(value, 0), 1) }

    var body: some View {
        ZStack {

            // 🔳 BACKGROUND
            capShape
                .fill(Color.black.opacity(0.45))

            // 🟥🟨🟩 HEALTH FILL
            GeometryReader { geo in
                healthGradient
                    .frame(
                        width: geo.size.width * v,
                        alignment: direction == .left ? .leading : .trailing
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: direction == .left ? .leading : .trailing
                    )
                    .mask(capShape)
                    .animation(.easeOut(duration: 0.25), value: v)
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 3)

            // ⚡ DAMAGE FLASH
            if damageFlash {
                capShape
                    .fill(Color.white.opacity(0.6))
            }

            // ✨ GLOSS
            capShape
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blendMode(.screen)

            // 🔥 LOW HP GLOW
            capShape
                .stroke(
                    v < 0.25 ? Color.red : Color.cyan.opacity(0.8),
                    lineWidth: 2
                )
                .blur(radius: v < 0.25 ? 6 : 3)
                .opacity(lowPulse ? 0.9 : 0.5)

            // 🧱 INNER OUTLINE
            capShape
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .frame(width: width, height: height)
        .onChange(of: v) { old, new in
            if new < old {
                triggerDamageFlash()
            }

            if new < 0.25 {
                startLowPulse()
            } else {
                lowPulse = false
            }
        }
    }

    // MARK: - Helpers

    private var capShape: some Shape {
        Cap(
            mirrored: direction == .right,
            cap: cap
        )
    }

    private var healthGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .yellow, .orange, .red],
            startPoint: direction == .left ? .leading : .trailing,
            endPoint: direction == .left ? .trailing : .leading
        )
    }

    private func triggerDamageFlash() {
        damageFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            damageFlash = false
        }
    }

    private func startLowPulse() {
        guard !lowPulse else { return }
        lowPulse = true
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
    VStack(spacing: 28) {
        SlantedHealthBar(value: 1.0, direction: .left)
        SlantedHealthBar(value: 0.72, direction: .right)
        SlantedHealthBar(value: 0.34, direction: .left)
        SlantedHealthBar(value: 0.15, direction: .right)
    }
    .padding(32)  // 👈 HUD-Rand
    .background(Color.black)
}
