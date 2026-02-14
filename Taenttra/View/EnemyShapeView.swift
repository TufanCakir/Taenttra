//
//  EnemyShapeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct EnemyShapeView: View {

    let enemy: Enemy

    var body: some View {
        Group {
            switch enemy.id {
            case "slime":
                SlimeShape()
                    .fill(Color.green)

            case "goblin":
                GoblinShape()
                    .fill(Color.orange)

            case "dragon":
                DragonShape()
                    .fill(Color.red)

            default:
                Rectangle()
                    .fill(Color.gray)
            }
        }
        .frame(width: 150, height: 150)
        .shadow(radius: 10)
    }
}
