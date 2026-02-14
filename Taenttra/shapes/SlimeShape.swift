//
//  SlimeShape.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct SlimeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRoundedRect(
            in: CGRect(
                x: rect.width * 0.1,
                y: rect.height * 0.3,
                width: rect.width * 0.8,
                height: rect.height * 0.6
            ),
            cornerSize: CGSize(width: 40, height: 40)
        )

        return path
    }
}
