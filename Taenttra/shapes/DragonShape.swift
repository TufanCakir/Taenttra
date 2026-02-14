//
//  DragonShape.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct DragonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addEllipse(in: rect)

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()

        return path
    }
}

