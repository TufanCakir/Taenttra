//
//  VersusViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Combine
import SwiftUI

@MainActor
final class VersusViewModel: ObservableObject {

    private enum Constants {
        static let defaultTimeLimit = 99
        static let attackDistance: CGFloat = 14
        static let enemyAdvanceDelay = 0.4
    }

    @Published private(set) var koOccurred: Bool = false

    // MARK: - Timer
    @Published var timeRemaining: Int = 0
    @Published var isTimerRunning: Bool = false

    @Published var currentEnemyIndex: Int = 0

    // MARK: - Animation
    @Published var leftAnimation: FighterAnimation = .idle
    @Published var rightAnimation: FighterAnimation = .idle

    @Published var leftAttackOffset: CGFloat = 0
    @Published var rightAttackOffset: CGFloat = 0

    // MARK: - Fight State
    @Published var fightState: FightState = .fighting
    @Published var winner: FighterSide?
    @Published var rewards: VictoryRewards?
    @Published var hitStopActive: Bool = false
    @Published var hitShakeOffset: CGFloat = 0

    // MARK: - Stages
    let stages: [VersusStage]

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
    private var leftIsAttacking = false
    private var rightIsAttacking = false
    private let attacks: [FighterAnimation] = [.punch, .kick]
    private var timerCancellable: AnyCancellable?

    private let gameState: GameState

    // MARK: - Enemy AI
    private var enemyAttackCancellable: AnyCancellable?
    private let enemyAttackInterval: ClosedRange<Double> = 1.2...2.4

    private var playerSide: FighterSide {
        gameState.playerSide
    }

    private var enemySide: FighterSide {
        playerSide == .left ? .right : .left
    }

    private var currentEnemyKey: String? {
        guard let wave = currentWave, wave.enemies.indices.contains(currentEnemyIndex) else {
            return nil
        }
        return wave.enemies[currentEnemyIndex]
    }

    // MARK: - Init
    init(stages: [VersusStage], gameState: GameState) {
        precondition(!stages.isEmpty, "VersusViewModel requires at least one stage.")
        self.stages = stages
        self.currentStage = stages[0]
        self.gameState = gameState
    }

    deinit {
        timerCancellable?.cancel()
        enemyAttackCancellable?.cancel()
    }

    private func startEnemyAttacks() {
        enemyAttackCancellable?.cancel()

        enemyAttackCancellable =
            Timer
            .publish(
                every: Double.random(in: enemyAttackInterval),
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                self?.enemyAttack()
            }
    }

    private func enemyAttack() {
        guard fightState == .fighting else { return }

        performRandomAttack(from: enemySide)
    }

    private func stopEnemyAttacks() {
        enemyAttackCancellable?.cancel()
        enemyAttackCancellable = nil
    }

    func startFight() {
        koOccurred = false
        rewards = nil
        winner = nil
        phase = .fighting

        currentWaveIndex = 0
        currentEnemyIndex = 0
        updateEnemyCharacter()
        prepareRound()
    }

    private func prepareRound() {
        stopCombatLoops()
        fightState = .fighting
        winner = nil
        resetRoundState()
        startTimer()
        startEnemyAttacks()
    }

    private func startTimer() {
        timerCancellable?.cancel()

        let limit =
            currentWave?.timeLimit
            ?? currentStage.waves.last?.timeLimit
            ?? Constants.defaultTimeLimit

        timeRemaining = limit
        isTimerRunning = true

        timerCancellable =
            Timer
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
        let winningSide: FighterSide = {
            if leftHealth > rightHealth {
                return .left
            }
            if rightHealth > leftHealth {
                return .right
            }
            return enemySide
        }()

        withAnimation(.easeOut(duration: 0.3)) {
            resetFighterPresentation()
        }

        finishFight(
            state: .victory,
            winner: winningSide,
            rewards: calculateRewards()
        )
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
        guard fightState == .fighting, beginAttack(for: side) else { return }

        let attack = attacks.randomElement() ?? .punch
        let config = data(for: attack)
        let target = opposingSide(of: side)

        animateAttack(attack, from: side)

        applyDamage(to: target, amount: config.damage, hitStop: config.hitStop)

        DispatchQueue.main.asyncAfter(deadline: .now() + config.recovery) {
            self.endAttack(for: side)
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
        let playerSide = self.playerSide
        let playerLost = loser == playerSide

        if playerLost {
            koOccurred = true
            let winner = opposingSide(of: loser)

            withAnimation(.easeOut(duration: 0.25)) {
                setAnimation(.ko, for: loser)
            }
            finishFight(state: .ko, winner: winner, rewards: nil)
        } else {
            winner = playerSide

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.advanceAfterKO()
            }
        }
    }

    private func advanceAfterKO() {
        guard let wave = currentWave else { return }

        if currentEnemyIndex + 1 < wave.enemies.count {
            currentEnemyIndex += 1
            updateEnemyCharacter()
            prepareRound()
            return
        }

        currentEnemyIndex = 0

        if currentWaveIndex + 1 < currentStage.waves.count {
            nextWave()
            prepareRound()
            return
        }

        handleVictory()
    }

    private func updateEnemyCharacter() {
        guard let enemyKey = currentEnemyKey else {
            currentEnemyIndex = 0
            return
        }

        let enemy = Character.enemy(
            key: enemyKey,
            skinId: nil
        )

        if playerSide == .left {
            gameState.rightCharacter = enemy
        } else {
            gameState.leftCharacter = enemy
        }
    }

    private func handleVictory() {
        finishFight(
            state: .victory,
            winner: playerSide,
            rewards: koOccurred ? nil : calculateRewards()
        )
    }

    // MARK: - Rewards
    private func calculateRewards() -> VictoryRewards {
        if case .story(_, let section) = gameState.pendingMode {
            if let rewards = section.rewards {
                return rewards
            }

            return .zero
        }

        let baseCoins = 100
        let baseCrystals = 5

        let waveBonus = currentStage.waves.count * 25
        let flawlessBonus = leftHealth > 0.8 ? 50 : 0

        let shards: Int = {
            guard case .eventMode(let event) = gameState.pendingMode else {
                return 0
            }
            return event.rewardShards
        }()

        return VictoryRewards(
            coins: baseCoins + waveBonus + flawlessBonus,
            crystals: baseCrystals + currentStage.waves.count,
            shards: shards
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
        currentEnemyIndex = 0
        updateEnemyCharacter()
    }

    private func resetRoundState() {
        leftHealth = 1
        rightHealth = 1
        hitStopActive = false
        hitShakeOffset = 0
        resetAttackState()
        resetFighterPresentation()
    }

    private func resetAttackState() {
        leftIsAttacking = false
        rightIsAttacking = false
    }

    private func resetFighterPresentation() {
        leftAnimation = .idle
        rightAnimation = .idle
        leftAttackOffset = 0
        rightAttackOffset = 0
    }

    private func stopCombatLoops() {
        timerCancellable?.cancel()
        timerCancellable = nil
        stopEnemyAttacks()
        isTimerRunning = false
    }

    private func finishFight(
        state: FightState,
        winner: FighterSide?,
        rewards: VictoryRewards?
    ) {
        stopCombatLoops()
        resetAttackState()
        self.winner = winner
        self.rewards = rewards

        withAnimation(.easeOut(duration: 0.3)) {
            fightState = state
        }
    }

    private func beginAttack(for side: FighterSide) -> Bool {
        switch side {
        case .left:
            guard !leftIsAttacking else { return false }
            leftIsAttacking = true
        case .right:
            guard !rightIsAttacking else { return false }
            rightIsAttacking = true
        }
        return true
    }

    private func endAttack(for side: FighterSide) {
        withAnimation(.easeOut(duration: 0.12)) {
            setAnimation(.idle, for: side)
            setAttackOffset(0, for: side)
        }

        switch side {
        case .left:
            leftIsAttacking = false
        case .right:
            rightIsAttacking = false
        }
    }

    private func animateAttack(_ attack: FighterAnimation, from side: FighterSide) {
        withAnimation(.easeOut(duration: 0.08)) {
            setAnimation(attack, for: side)
            let direction: CGFloat = side == .left ? 1 : -1
            setAttackOffset(Constants.attackDistance * direction, for: side)
        }
    }

    private func setAnimation(_ animation: FighterAnimation, for side: FighterSide) {
        switch side {
        case .left:
            leftAnimation = animation
        case .right:
            rightAnimation = animation
        }
    }

    private func setAttackOffset(_ value: CGFloat, for side: FighterSide) {
        switch side {
        case .left:
            leftAttackOffset = value
        case .right:
            rightAttackOffset = value
        }
    }

    private func opposingSide(of side: FighterSide) -> FighterSide {
        side == .left ? .right : .left
    }
}
