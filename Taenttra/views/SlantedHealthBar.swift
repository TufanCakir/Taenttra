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
    private let cap: CGFloat = 18
    @State private var flash = false
    
    private var v: CGFloat { min(max(value, 0), 1) }
    
    var body: some View {
        ZStack {
            
            // 🔳 Base
            Rectangle()
                .fill(flash ? Color.white.opacity(0.6) : Color.black.opacity(0.35))
                .mask(capShape)
            
            // 🟥🟨🟩 Health Fill
            Rectangle()
                .fill(healthGradient)
                .overlay(
                    HStack(spacing: 6) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.25))
                                .frame(width: 2)
                        }
                    }
                        .padding(.horizontal, 10)
                        .mask(capShape)
                )
                .opacity(v < 0.2 ? 0.85 : 1)
                .scaleEffect(v < 0.2 ? 1.02 : 1)
                .animation(
                    v < 0.2
                    ? .easeInOut(duration: 0.4).repeatForever(autoreverses: true)
                    : .default,
                    value: v < 0.2
                )
                .scaleEffect(
                    x: v,
                    y: 1,
                    anchor: direction == .left ? .leading : .trailing
                )
                .mask(capShape)
                .padding(2)
            
            // ✨ Gloss
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxHeight: .infinity, alignment: .top)
                .mask(capShape)
            
            // ✨ Glow
            capShape
                .stroke(
                    v < 0.25 ? Color.red : Color.cyan,
                    lineWidth: 2
                )
                .blur(radius: 4)
            
            // 🧱 Inner Outline
            capShape
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        }
        .frame(width: width, height: 20)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeOut(duration: 0.25), value: v)
        .onChange(of: v) { old, new in
            if new < old {
                flash = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    flash = false
                }
            }
        }
    }
    
    
    // MARK: - Mask
    private var capShape: some Shape {
        Cap(
            mirrored: direction == .right,
            cap: cap
        )
    }
    
    // MARK: - Gradient
    private var healthGradient: LinearGradient {
        LinearGradient(
            colors: [
                .green,
                .yellow,
                .orange,
                .red
            ],
            startPoint: direction == .left ? .leading : .trailing,
            endPoint: direction == .left ? .trailing : .leading
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
