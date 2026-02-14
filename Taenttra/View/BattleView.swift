//
//  BattleView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct BattleView: View {

    let level: Level
    @Environment(\.dismiss) var dismiss
    @StateObject private var battleVM: BattleViewModel

    // 👇 Custom Init
    init(level: Level) {
        self.level = level
        _battleVM = StateObject(wrappedValue: BattleViewModel(level: level))
    }

    var body: some View {
        ZStack {

            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {

                Text("Battle")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Text("Level: \(level.number)")
                    .foregroundColor(.white)

                if let enemy = battleVM.currentEnemy {
                    EnemyShapeView(enemy: enemy)

                    Text("Enemy HP: \(enemy.hp)")
                        .foregroundColor(.white)
                }

                if let player = battleVM.player {
                    Text("Player HP: \(battleVM.playerCurrentHP)")
                        .foregroundColor(.green)

                    Text("Level: \(player.level)")
                        .foregroundColor(.white)
                }

                Button("Angreifen") {
                    battleVM.attack()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Zurück") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }
}
