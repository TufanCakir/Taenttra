//
//  VersusViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Combine
import SwiftUI

final class VersusViewModel: ObservableObject {
    
    // MARK: - Timer
    @Published var timeRemaining: Int = 0
    @Published var isTimerRunning: Bool = false


    // MARK: - Animation
    @Published var animationState: FighterAnimation = .idle
    @Published var attackOffset: CGFloat = 0

    // MARK: - Fight State
    @Published var fightState: FightState = .fighting
    @Published var winner: FighterSide?
    @Published var rewards: VictoryRewards?
    @Published var hitStopActive: Bool = false
    @Published var hitShakeOffset: CGFloat = 0

    // MARK: - Stages
    let stages: [VersusStage]
    @Published var currentStageIndex: Int = 0

    @Published var currentStage: VersusStage
    @Published var currentWaveIndex: Int = 0
    @Published var phase: VersusPhase = .intro

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
    private var timerCancellable: AnyCancellable?

    // MARK: - Init
    init(stages: [VersusStage]) {
        self.stages = stages
        self.currentStage = stages.first!
        self.phase = .intro
        startTimer() // 🔥 DAS FEHLTE
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
    
    func startFight() {
        phase = .fighting
        startTimer()
    }
    
    private func resetForNextWave() {
        fightState = .fighting
        winner = nil
        leftHealth = 1
        rightHealth = 1
        animationState = .idle

        startTimer()
    }
    
    private func startTimer() {
        timerCancellable?.cancel()

        let limit = currentWave?.timeLimit
            ?? currentStage.waves.last?.timeLimit
            ?? 99

        timeRemaining = limit
        isTimerRunning = true

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard fightState == .fighting else { return }

        timeRemaining -= 1

        if timeRemaining <= 0 {
            handleTimeout()
        }
    }
    
    private func handleTimeout() {
        timerCancellable?.cancel()
        isTimerRunning = false

        // Wer hat mehr HP?
        if leftHealth > rightHealth {
            handleKO(loser: .right)
        } else if rightHealth > leftHealth {
            handleKO(loser: .left)
        } else {
            // Draw → Gegner gewinnt oder Sudden Death
            handleKO(loser: .left)
        }
    }

    private func triggerHitStop(duration: Double) {
        hitStopActive = true
        hitShakeOffset = -6

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hitStopActive = false
            withAnimation(.easeOut(duration: 0.1)) {
                self.hitShakeOffset = 0
            }
        }
    }

    private func data(for attack: FighterAnimation) -> AttackData {
        switch attack {
        case .punch:
            return AttackData(damage: 0.06, hitStop: 0.04, recovery: 0.18)
        case .kick:
            return AttackData(damage: 0.1, hitStop: 0.06, recovery: 0.24)
        default:
            return AttackData(damage: 0, hitStop: 0, recovery: 0)
        }
    }

    // MARK: - Attack
    func performRandomAttack(from side: FighterSide = .left) {
        guard !isAttacking, fightState == .fighting else { return }
        isAttacking = true

        let attack = attacks.randomElement() ?? .punch
        let config = data(for: attack)
        let target: FighterSide = side == .left ? .right : .left

        withAnimation(.easeOut(duration: 0.08)) {
            animationState = attack
            attackOffset = 14
        }

        applyDamage(to: target, amount: config.damage, hitStop: config.hitStop)

        DispatchQueue.main.asyncAfter(deadline: .now() + config.recovery) {
            withAnimation(.easeOut(duration: 0.12)) {
                self.attackOffset = 0
                self.animationState = .idle
            }
            self.isAttacking = false
        }
    }

    // MARK: - Damage
    private func applyDamage(
        to side: FighterSide,
        amount: CGFloat,
        hitStop: Double
    ) {
        guard fightState == .fighting else { return }

        triggerHitStop(duration: hitStop)

        let newHealth = max(0, health(for: side) - amount)
        setHealth(newHealth, for: side)

        if newHealth <= 0 {
            handleKO(loser: side)
        }
    }

    private func handleKO(loser: FighterSide) {
        timerCancellable?.cancel()
          isTimerRunning = false
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
    
    private func handleVictory() {
        timerCancellable?.cancel()
        isTimerRunning = false

        rewards = calculateRewards()

        let score = calculateLeaderboardScore()
        if GameCenterManager.shared.isAuthenticated {
            Task {
                await GameCenterManager.shared.submitScore(score)
            }
        }

        withAnimation(.easeOut(duration: 0.3)) {
            fightState = .victory
        }
    }

    private func calculateLeaderboardScore() -> Int {

        let stageScore = (currentStageIndex + 1) * 1_000
        let waveScore = currentWaveIndex * 250
        let healthBonus = Int(leftHealth * 1_000)

        return stageScore + waveScore + healthBonus
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
