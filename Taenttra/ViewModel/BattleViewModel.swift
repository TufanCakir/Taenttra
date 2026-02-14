//
//  BattleViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation
import Combine

class BattleViewModel: ObservableObject {

    // MARK: - Published
    @Published var player: Player?
    @Published var currentEnemy: Enemy?
    @Published var playerCurrentHP: Int = 100
    @Published var coins: Int = 0
    @Published var battleLog: String = ""
    @Published var isBattleOver: Bool = false

    // MARK: - Private
    private var enemies: [Enemy] = []
    private let level: Level

    // MARK: - Init
    init(level: Level) {
        self.level = level
        loadPlayer()
        loadEnemies()
        spawnEnemy()
    }

    // MARK: - Load Player
    private func loadPlayer() {
        guard let url = Bundle.main.url(forResource: "player", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(Player.self, from: data)
        else {
            print("Player JSON Fehler")
            return
        }

        player = decoded
        playerCurrentHP = 100 + (decoded.level * 10)
    }

    // MARK: - Load Enemies
    private func loadEnemies() {
        guard let url = Bundle.main.url(forResource: "enemies", withExtension: "json") else {
            print("enemies.json nicht gefunden ❌")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            enemies = try JSONDecoder().decode([Enemy].self, from: data)
            print("Enemies geladen:", enemies.count)
        } catch {
            print("DECODE ERROR:", error)
        }
    }

    // MARK: - Spawn Enemy
    func spawnEnemy() {
        guard !enemies.isEmpty else {
            print("Keine Enemies geladen")
            return
        }

        // Boss auf Level 3
        if level.number == 3 {
            currentEnemy = enemies.first(where: { $0.id == "dragon" }) ?? enemies.randomElement()
        } else {
            currentEnemy = enemies.randomElement()
        }
    }

    // MARK: - Attack
    func attack() {
        guard !isBattleOver,
              var enemy = currentEnemy,
              let player = player
        else { return }

        // Player greift an
        enemy.hp -= player.attack
        battleLog = "Du triffst \(enemy.name) für \(player.attack) Schaden."

        if enemy.hp <= 0 {
            enemyDefeated(enemy)
            return
        }

        currentEnemy = enemy

        // Enemy greift zurück
        enemyAttack()
    }

    // MARK: - Enemy Attack
    private func enemyAttack() {
        guard let enemy = currentEnemy else { return }

        playerCurrentHP -= enemy.attack
        battleLog += "\n\(enemy.name) trifft dich für \(enemy.attack) Schaden."

        if playerCurrentHP <= 0 {
            battleLost()
        }
    }

    // MARK: - Enemy Defeated
    private func enemyDefeated(_ enemy: Enemy) {
        battleLog += "\n\(enemy.name) besiegt! 💀"

        coins += enemy.coinDrop
        gainExp(enemy.expDrop)

        spawnEnemy()
    }

    // MARK: - EXP System
    private func gainExp(_ amount: Int) {
        guard var player = player else { return }

        player.exp += amount

        while player.exp >= player.expToNextLevel {
            player.exp -= player.expToNextLevel
            player.level += 1
            player.expToNextLevel += 50
            battleLog += "\nLevel Up! 🎉"
        }

        self.player = player
    }

    // MARK: - Battle Lost
    private func battleLost() {
        isBattleOver = true
        battleLog += "\nDu wurdest besiegt... ☠️"
    }

    // MARK: - Reset
    func resetBattle() {
        isBattleOver = false
        loadPlayer()
        spawnEnemy()
    }
}
