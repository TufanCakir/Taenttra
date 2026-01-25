//
//  VersusViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Combine
import SwiftUI

final class VersusViewModel: ObservableObject {

    // MARK: - Animation
    @Published var animationState: FighterAnimation = .idle
    @Published var attackOffset: CGFloat = 0

    // MARK: - Fight State
    @Published var fightState: FightState = .fighting
    @Published var winner: FighterSide?
    @Published var rewards: VictoryRewards?

    // MARK: - Stages
    let stages: [VersusStage]
    @Published var currentStageIndex: Int = 0

    @Published var currentStage: VersusStage
    @Published var currentWaveIndex: Int = 0

    var currentWave: VersusWave? {
        guard currentWaveIndex < currentStage.waves.count else {
            return nil
        }
        return currentStage.waves[currentWaveIndex]
    }

    // MARK: - Health
    @Published var leftHealth: CGFloat = 1.0
    @Published var rightHealth: CGFloat = 1.0

    // MARK: - Private
    private var isAttacking = false
    private let attacks: [FighterAnimation] = [.punch, .kick]

    // MARK: - Init
    init(stages: [VersusStage]) {
        self.stages = stages
        self.currentStage = stages.first!
    }

    func loadStage(_ stage: VersusStage) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentStage = stage
        }

        currentWaveIndex = 0
        leftHealth = 1
        rightHealth = 1
        fightState = .fighting
        animationState = .idle
    }

    // MARK: - Attack
    func performRandomAttack(from side: FighterSide = .left) {
        guard !isAttacking, fightState == .fighting else { return }
        isAttacking = true

        let attack = attacks.randomElement() ?? .punch
        let damage: CGFloat = attack == .punch ? 0.06 : 0.1
        let target = side == .left ? FighterSide.right : .left

        withAnimation(.easeOut(duration: 0.1)) {
            animationState = attack
            attackOffset = 14
        }

        applyDamage(to: target, amount: damage)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.12)) {
                self.attackOffset = 0
                self.animationState = .idle
            }
            self.isAttacking = false
        }
    }

    // MARK: - Damage
    private func applyDamage(to side: FighterSide, amount: CGFloat) {
        guard fightState == .fighting else { return }

        let newHealth = max(0, health(for: side) - amount)
        setHealth(newHealth, for: side)

        if newHealth <= 0 {
            handleKO(loser: side)
        }
    }

    private func handleKO(loser: FighterSide) {
        fightState = .ko
        winner = loser == .left ? .right : .left

        withAnimation(.easeOut(duration: 0.25)) {
            animationState = .ko
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.advanceAfterKO()
        }
    }

    private func advanceAfterKO() {

        // 🟢 nächste Wave
        if currentWaveIndex + 1 < currentStage.waves.count {
            nextWave()
            resetForNextWave()
            return
        }

        // 🟡 nächster Stage
        if currentStageIndex + 1 < stages.count {
            currentStageIndex += 1
            loadStage(stages[currentStageIndex])
            return
        }

        handleVictory()
    }

    private func resetForNextWave() {
        fightState = .fighting
        winner = nil
        leftHealth = 1
        rightHealth = 1
        animationState = .idle
    }

    private func handleVictory() {
        rewards = calculateRewards()

        withAnimation(.easeOut(duration: 0.3)) {
            fightState = .victory
        }
    }

    // MARK: - Rewards
    private func calculateRewards() -> VictoryRewards {
        let baseCoins = 100
        let baseCrystals = 5

        let waveBonus = currentStage.waves.count * 25
        let flawlessBonus = leftHealth > 0.8 ? 50 : 0

        return VictoryRewards(
            coins: baseCoins + waveBonus + flawlessBonus,
            crystals: baseCrystals + currentStage.waves.count
        )
    }

    // MARK: - Health Helpers
    private func health(for side: FighterSide) -> CGFloat {
        side == .left ? leftHealth : rightHealth
    }

    private func setHealth(_ value: CGFloat, for side: FighterSide) {
        withAnimation(.easeOut(duration: 0.4)) {
            if side == .left {
                leftHealth = value
            } else {
                rightHealth = value
            }
        }
    }

    // MARK: - Wave
    func nextWave() {
        guard currentWaveIndex + 1 < currentStage.waves.count else { return }
        currentWaveIndex += 1
    }
}
