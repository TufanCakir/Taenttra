//
//  SpiritGridBackground.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct SpiritGridBackground: View {

    let style: BackgroundStyle
    var intensity: Double = 1.0

    var body: some View {
        Group {
            if style.isPNG {
                pngBackground
            } else {
                gridBackground
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}

extension SpiritGridBackground {

    fileprivate var pngBackground: some View {
        Image(style.imageName)
            .resizable()
            .scaledToFill()
    }
}

extension SpiritGridBackground {

    fileprivate var gridBackground: some View {
        TimelineView(.animation) { timeline in

            let gridSize: CGFloat = 50
            let lineWidth: CGFloat = 1.2

            let t = timeline.date.timeIntervalSinceReferenceDate
            let offset = CGFloat(t.remainder(dividingBy: gridSize))
            let slowOffset = CGFloat((t * 0.35).remainder(dividingBy: gridSize))

            Canvas { context, size in

                // Hintergrund-Gradient
                let bgGradient = Gradient(colors: [
                    .black,
                    style.glowColor.opacity(0.15 * intensity),
                    .black,
                ])

                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        bgGradient,
                        startPoint: CGPoint(x: 0.5, y: 0),
                        endPoint: CGPoint(x: 0.5, y: 1)
                    )
                )

                context.blendMode = .plusLighter
                var path = Path()

                // Vertikale Linien
                for x in stride(from: 0, through: size.width, by: gridSize) {
                    let xx = x + offset
                    path.move(to: CGPoint(x: xx, y: 0))
                    path.addLine(to: CGPoint(x: xx, y: size.height))
                }

                // Horizontale Linien
                for y in stride(from: 0, through: size.height, by: gridSize) {
                    let yy = y + slowOffset
                    path.move(to: CGPoint(x: 0, y: yy))
                    path.addLine(to: CGPoint(x: size.width, y: yy))
                }

                let strong = intensity

                // Basis-Linien
                context.stroke(
                    path,
                    with: .color(style.glowColor.opacity(0.35 * strong)),
                    lineWidth: lineWidth
                )

                // Glow
                context.addFilter(
                    .shadow(
                        color: style.glowColor.opacity(0.9 * strong),
                        radius: 12 * strong
                    )
                )

                context.drawLayer { layer in
                    layer.stroke(
                        path,
                        with: .color(style.glowColor.opacity(0.85 * strong)),
                        lineWidth: lineWidth
                    )
                }
            }
        }
    }
}

#Preview {
    SpiritGridBackground(style: .purpleGrid, intensity: 1.2)
}
