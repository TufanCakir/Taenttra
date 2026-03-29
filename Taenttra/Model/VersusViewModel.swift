//
//  VersusViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Combine
import SwiftUI

struct BattleCard: Identifiable, Equatable {
    let id: UUID
    let templateID: String
    let title: String
    let subtitle: String
    let power: Int
    let role: BattleCardRole
    let rarity: BattleCardRarity
    let energyCost: Int
    let accentColor: Color
    let frameColor: Color
    let artworkName: String
    let skillText: String
    let ultimateText: String
    let isEnemy: Bool
    let slot: Int
    let transformCharge: Int
    let transformThreshold: Int?
    let transformIntoID: String?
    let isTransformed: Bool
}

@MainActor
final class VersusViewModel: ObservableObject {

    private enum Constants {
        static let defaultTimeLimit = 99
        static let attackDistance: CGFloat = 14
        static let cardHPScale: CGFloat = 0.0105
        static let startingEnergy: Int = 3
        static let maxEnergy: Int = 5
        static let handSize: Int = 3
    }

    private struct CardEffectPayload {
        let damageMultiplier: CGFloat
        let bonusDamage: CGFloat
        let shieldGain: CGFloat
        let boostGain: Int
        let energyGain: Int
        let stripBoost: Bool
        let shieldPierce: CGFloat
        let isUltimate: Bool
        let actionSuffix: String
    }

    struct TransformationShowcase: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
        let artworkName: String
        let rarity: BattleCardRarity
        let accentColor: Color
        let frameColor: Color
        let side: FighterSide
    }

    @Published private(set) var koOccurred: Bool = false

    @Published var timeRemaining: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var currentEnemyIndex: Int = 0

    @Published var leftAnimation: FighterAnimation = .idle
    @Published var rightAnimation: FighterAnimation = .idle
    @Published var leftAttackOffset: CGFloat = 0
    @Published var rightAttackOffset: CGFloat = 0

    @Published var fightState: FightState = .fighting
    @Published var winner: FighterSide?
    @Published var rewards: VictoryRewards?
    @Published var hitStopActive: Bool = false
    @Published var hitShakeOffset: CGFloat = 0

    @Published var currentStage: VersusStage
    @Published var currentWaveIndex: Int = 0
    @Published var phase: VersusPhase = .intro

    @Published var leftHealth: CGFloat = 1.0
    @Published var rightHealth: CGFloat = 1.0

    @Published var playerCards: [BattleCard] = []
    @Published var enemyCards: [BattleCard] = []
    @Published var selectedPlayerCardID: BattleCard.ID?
    @Published var highlightedPlayerCardID: BattleCard.ID?
    @Published var highlightedEnemyCardID: BattleCard.ID?
    @Published var lastActionText: String = "DRAW OPENING HAND"
    @Published var playerEnergy: Int = Constants.startingEnergy
    @Published var enemyEnergy: Int = Constants.startingEnergy
    @Published var maxEnergy: Int = Constants.maxEnergy
    @Published var playerDeckCount: Int = 0
    @Published var enemyDeckCount: Int = 0
    @Published var playerShield: CGFloat = 0
    @Published var enemyShield: CGFloat = 0
    @Published var playerBoostStacks: Int = 0
    @Published var enemyBoostStacks: Int = 0
    @Published var playerStatusText: String = "NEUTRAL"
    @Published var enemyStatusText: String = "NEUTRAL"
    @Published var transformationShowcase: TransformationShowcase?

    let stages: [VersusStage]

    var currentWave: VersusWave? {
        guard currentWaveIndex < currentStage.waves.count else {
            return nil
        }
        return currentStage.waves[currentWaveIndex]
    }

    private var leftIsAttacking = false
    private var rightIsAttacking = false
    private let attacks: [FighterAnimation] = [.punch, .kick]
    private var timerCancellable: AnyCancellable?
    private var enemyAttackCancellable: AnyCancellable?
    private let enemyAttackInterval: ClosedRange<Double> = 1.4...2.6
    private let catalog = BattleCardLoader.load()

    private let gameState: GameState
    private var playerDeck: [BattleCard] = []
    private var enemyDeck: [BattleCard] = []

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

    private var selectedPlayerCard: BattleCard? {
        guard let selectedPlayerCardID else { return nil }
        return playerCards.first(where: { $0.id == selectedPlayerCardID })
    }

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

    func selectPlayerCard(_ cardID: BattleCard.ID) {
        guard playerCards.contains(where: { $0.id == cardID }) else { return }
        selectedPlayerCardID = cardID
    }

    func performRandomAttack(from side: FighterSide = .left) {
        if side == playerSide {
            guard let card = selectedPlayerCard ?? firstAffordablePlayerCard else { return }
            performCardAttack(with: card)
            return
        }

        performEnemyCardAttack()
    }

    func performCardAttack(with card: BattleCard) {
        guard fightState == .fighting, phase == .fighting else { return }
        selectPlayerCard(card.id)

        guard card.energyCost <= playerEnergy else {
            lastActionText = "NEED \(card.energyCost) KI FOR \(card.title.uppercased())"
            return
        }

        guard beginAttack(for: playerSide) else { return }
        guard let liveCard = playerCards.first(where: { $0.id == card.id }) else {
            endAttack(for: playerSide)
            return
        }

        resolveAttack(
            from: liveCard,
            attackerSide: playerSide,
            targetSide: enemySide
        )
    }

    private func prepareRound() {
        stopCombatLoops()
        fightState = .fighting
        winner = nil
        resetRoundState()
        buildBattleSetup()
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
                self?.performEnemyCardAttack()
            }
    }

    private func stopEnemyAttacks() {
        enemyAttackCancellable?.cancel()
        enemyAttackCancellable = nil
    }

    private func performEnemyCardAttack() {
        guard fightState == .fighting, phase == .fighting else { return }

        guard let enemyCard = firstAffordableEnemyCard else {
            enemyEnergy = min(maxEnergy, enemyEnergy + 1)
            lastActionText = "ENEMY CHARGES KI"
            return
        }

        guard beginAttack(for: enemySide) else { return }

        resolveAttack(
            from: enemyCard,
            attackerSide: enemySide,
            targetSide: playerSide
        )
    }

    private func resolveAttack(
        from card: BattleCard,
        attackerSide: FighterSide,
        targetSide: FighterSide
    ) {
        let attack = attacks.randomElement() ?? .punch
        let config = data(for: attack)
        let effect = effectPayload(for: card, attackerSide: attackerSide, targetSide: targetSide)
        let damage = effectiveDamage(for: card, baseDamage: config.damage) * effect.damageMultiplier + effect.bonusDamage

        spendEnergy(card.energyCost, for: attackerSide)
        animateAttack(attack, from: attackerSide)
        highlight(cardID: card.id, for: attackerSide)
        applyEffectPayload(effect, attackerSide: attackerSide, targetSide: targetSide)
        lastActionText = actionText(
            for: card,
            attackerSide: attackerSide,
            damage: damage,
            effectText: effect.isUltimate ? "ULTIMATE • \(effect.actionSuffix)" : effect.actionSuffix
        )

        applyDamage(
            to: targetSide,
            amount: damage,
            hitStop: config.hitStop,
            shieldPierce: effect.shieldPierce
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + config.recovery) {
            let retainedCard = self.advanceTransformation(for: card, effect: effect, attackerSide: attackerSide)
            if !retainedCard {
                self.replaceUsedCard(card, for: attackerSide)
            }
            self.recoverEnergyAfterExchange()
            self.clearHighlights()
            self.endAttack(for: attackerSide)
        }
    }

    private func handleTimeout() {
        let winningSide: FighterSide = {
            if leftHealth > rightHealth { return .left }
            if rightHealth > leftHealth { return .right }
            return enemySide
        }()

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

    private func applyDamage(
        to side: FighterSide,
        amount: CGFloat,
        hitStop: Double,
        shieldPierce: CGFloat = 0
    ) {
        guard fightState == .fighting else { return }

        triggerHitStop(duration: hitStop)

        let mitigatedAmount = consumeShield(for: side, incomingDamage: amount, shieldPierce: shieldPierce)
        let newHealth = max(0, health(for: side) - mitigatedAmount)
        setHealth(newHealth, for: side)

        if newHealth <= 0 {
            handleKO(loser: side)
        }
    }

    private func handleKO(loser: FighterSide) {
        let playerLost = loser == playerSide

        if playerLost {
            koOccurred = true
            finishFight(state: .ko, winner: opposingSide(of: loser), rewards: nil)
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

        let enemy = Character.enemy(key: enemyKey, skinId: nil)

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

    private func health(for side: FighterSide) -> CGFloat {
        side == .left ? leftHealth : rightHealth
    }

    private func setHealth(_ value: CGFloat, for side: FighterSide) {
        withAnimation(.easeOut(duration: 0.35)) {
            if side == .left {
                leftHealth = value
            } else {
                rightHealth = value
            }
        }
    }

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
        lastActionText = "DRAW OPENING HAND"
        highlightedPlayerCardID = nil
        highlightedEnemyCardID = nil
        playerEnergy = Constants.startingEnergy
        enemyEnergy = Constants.startingEnergy
        playerCards = []
        enemyCards = []
        playerDeck = []
        enemyDeck = []
        playerDeckCount = 0
        enemyDeckCount = 0
        playerShield = 0
        enemyShield = 0
        playerBoostStacks = 0
        enemyBoostStacks = 0
        playerStatusText = "NEUTRAL"
        enemyStatusText = "NEUTRAL"
        transformationShowcase = nil
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

    private var firstAffordablePlayerCard: BattleCard? {
        playerCards.first(where: { $0.energyCost <= playerEnergy })
    }

    private var firstAffordableEnemyCard: BattleCard? {
        enemyCards
            .filter { $0.energyCost <= enemyEnergy }
            .sorted { $0.power > $1.power }
            .first
    }

    private func buildBattleSetup() {
        let playerCharacter = playerSide == .left ? gameState.leftCharacter : gameState.rightCharacter
        let enemyCharacter = playerSide == .left ? gameState.rightCharacter : gameState.leftCharacter

        playerDeck = makeDeck(for: playerCharacter, side: playerSide, usesSelectedDeck: true)
        enemyDeck = makeDeck(for: enemyCharacter, side: enemySide)

        playerCards = drawHand(from: &playerDeck)
        enemyCards = drawHand(from: &enemyDeck)
        playerDeckCount = playerDeck.count
        enemyDeckCount = enemyDeck.count
        selectedPlayerCardID = playerCards.first?.id
        lastActionText = "KI ONLINE  -  SELECT CARD"
    }

    private func makeDeck(for character: Character?, side: FighterSide) -> [BattleCard] {
        makeDeck(for: character, side: side, usesSelectedDeck: false)
    }

    private func makeDeck(
        for character: Character?,
        side: FighterSide,
        usesSelectedDeck: Bool
    ) -> [BattleCard] {
        let templates: [BattleCardTemplate]
        if usesSelectedDeck {
            templates = BattleDeckService.resolvePlayerTemplates(
                wallet: gameState.wallet,
                selectedCharacterKey: character?.key,
                in: catalog
            )
        } else {
            templates = BattleDeckService.templates(for: character?.key, in: catalog)
        }
        let fallbackArtwork = character?.spriteName(for: .idle) ?? "char_kenji_base_idle"
        let name = character?.key.replacingOccurrences(of: "_", with: " ").capitalized ?? "Unknown"
        let palette = cardPalette(for: side)

        var cards: [BattleCard] = []

        for cycle in 0..<2 {
            for (index, template) in templates.enumerated() {
                cards.append(
                    BattleCard(
                        id: UUID(),
                        templateID: template.id,
                        title: template.title.isEmpty ? name : template.title,
                        subtitle: template.subtitle,
                        power: template.power + cycle * 180 + currentWaveIndex * 120 + currentEnemyIndex * 90,
                        role: template.role,
                        rarity: template.rarity,
                        energyCost: template.energyCost,
                        accentColor: palette.accent,
                        frameColor: palette.frame,
                        artworkName: template.artworkName ?? fallbackArtwork,
                        skillText: template.skillText,
                        ultimateText: template.ultimateText,
                        isEnemy: side == enemySide,
                        slot: index,
                        transformCharge: 0,
                        transformThreshold: template.transformThreshold,
                        transformIntoID: template.transformIntoID,
                        isTransformed: template.isTransformVariant == true
                    )
                )
            }
        }

        return cards.shuffled()
    }

    private func drawHand(from deck: inout [BattleCard]) -> [BattleCard] {
        var hand: [BattleCard] = []
        for index in 0..<Constants.handSize {
            guard !deck.isEmpty else { break }
            var card = deck.removeFirst()
            card = BattleCard(
                id: card.id,
                templateID: card.templateID,
                title: card.title,
                subtitle: card.subtitle,
                power: card.power,
                role: card.role,
                rarity: card.rarity,
                energyCost: card.energyCost,
                accentColor: card.accentColor,
                frameColor: card.frameColor,
                artworkName: card.artworkName,
                skillText: card.skillText,
                ultimateText: card.ultimateText,
                isEnemy: card.isEnemy,
                slot: index,
                transformCharge: card.transformCharge,
                transformThreshold: card.transformThreshold,
                transformIntoID: card.transformIntoID,
                isTransformed: card.isTransformed
            )
            hand.append(card)
        }
        return hand
    }

    private func replaceUsedCard(_ usedCard: BattleCard, for side: FighterSide) {
        switch side {
        case playerSide:
            playerCards.removeAll { $0.id == usedCard.id }
            refillHand(for: side)
            selectedPlayerCardID = firstAffordablePlayerCard?.id ?? playerCards.first?.id
        case enemySide:
            enemyCards.removeAll { $0.id == usedCard.id }
            refillHand(for: side)
        default:
            break
        }
    }

    private func refillHand(for side: FighterSide) {
        switch side {
        case playerSide:
            while playerCards.count < Constants.handSize, !playerDeck.isEmpty {
                var card = playerDeck.removeFirst()
                card = BattleCard(
                    id: card.id,
                    templateID: card.templateID,
                    title: card.title,
                    subtitle: card.subtitle,
                    power: card.power,
                    role: card.role,
                    rarity: card.rarity,
                    energyCost: card.energyCost,
                    accentColor: card.accentColor,
                    frameColor: card.frameColor,
                    artworkName: card.artworkName,
                    skillText: card.skillText,
                    ultimateText: card.ultimateText,
                    isEnemy: card.isEnemy,
                    slot: playerCards.count,
                    transformCharge: card.transformCharge,
                    transformThreshold: card.transformThreshold,
                    transformIntoID: card.transformIntoID,
                    isTransformed: card.isTransformed
                )
                playerCards.append(card)
            }
            playerDeckCount = playerDeck.count
        case enemySide:
            while enemyCards.count < Constants.handSize, !enemyDeck.isEmpty {
                var card = enemyDeck.removeFirst()
                card = BattleCard(
                    id: card.id,
                    templateID: card.templateID,
                    title: card.title,
                    subtitle: card.subtitle,
                    power: card.power,
                    role: card.role,
                    rarity: card.rarity,
                    energyCost: card.energyCost,
                    accentColor: card.accentColor,
                    frameColor: card.frameColor,
                    artworkName: card.artworkName,
                    skillText: card.skillText,
                    ultimateText: card.ultimateText,
                    isEnemy: card.isEnemy,
                    slot: enemyCards.count,
                    transformCharge: card.transformCharge,
                    transformThreshold: card.transformThreshold,
                    transformIntoID: card.transformIntoID,
                    isTransformed: card.isTransformed
                )
                enemyCards.append(card)
            }
            enemyDeckCount = enemyDeck.count
        default:
            break
        }
    }

    private func cardPalette(for side: FighterSide) -> (accent: Color, frame: Color) {
        if side == playerSide {
            return (Color.cyan, Color.blue)
        }
        return (Color.orange, Color.red)
    }

    private func effectiveDamage(for card: BattleCard, baseDamage: CGFloat) -> CGFloat {
        let scaledPower = CGFloat(card.power) * Constants.cardHPScale
        let rarityBonus: CGFloat

        switch card.rarity {
        case .common:
            rarityBonus = 0
        case .rare:
            rarityBonus = 0.01
        case .epic:
            rarityBonus = 0.02
        case .legendary:
            rarityBonus = 0.035
        }

        switch card.role {
        case .attacker:
            return scaledPower * (baseDamage + 0.03 + rarityBonus)
        case .booster:
            return scaledPower * (baseDamage + 0.018 + rarityBonus)
        case .guardUnit:
            return scaledPower * (baseDamage + 0.024 + rarityBonus)
        }
    }

    private func actionText(for card: BattleCard, attackerSide: FighterSide, damage: CGFloat) -> String {
        actionText(for: card, attackerSide: attackerSide, damage: damage, effectText: nil)
    }

    private func actionText(
        for card: BattleCard,
        attackerSide: FighterSide,
        damage: CGFloat,
        effectText: String?
    ) -> String {
        let origin = attackerSide == playerSide ? "PLAYER" : "ENEMY"
        let percentage = Int((damage * 100).rounded())
        if let effectText, !effectText.isEmpty {
            return "\(origin) \(card.title.uppercased())  -\(percentage)  •  \(effectText)"
        }
        return "\(origin) \(card.title.uppercased())  -\(percentage)"
    }

    private func spendEnergy(_ amount: Int, for side: FighterSide) {
        if side == playerSide {
            playerEnergy = max(0, playerEnergy - amount)
        } else {
            enemyEnergy = max(0, enemyEnergy - amount)
        }
    }

    private func recoverEnergyAfterExchange() {
        playerEnergy = min(maxEnergy, playerEnergy + 1)
        enemyEnergy = min(maxEnergy, enemyEnergy + 1)
    }

    private func advanceTransformation(
        for card: BattleCard,
        effect: CardEffectPayload,
        attackerSide: FighterSide
    ) -> Bool {
        guard
            let threshold = card.transformThreshold,
            let transformIntoID = card.transformIntoID,
            !card.isTransformed
        else {
            return false
        }

        let chargeGain = transformChargeGain(for: card, effect: effect)
        let updatedCharge = min(threshold, card.transformCharge + chargeGain)

        guard updatedCharge >= threshold else {
            updateCard(card.id, for: attackerSide) { current in
                BattleCard(
                    id: current.id,
                    templateID: current.templateID,
                    title: current.title,
                    subtitle: current.subtitle,
                    power: current.power,
                    role: current.role,
                    rarity: current.rarity,
                    energyCost: current.energyCost,
                    accentColor: current.accentColor,
                    frameColor: current.frameColor,
                    artworkName: current.artworkName,
                    skillText: current.skillText,
                    ultimateText: current.ultimateText,
                    isEnemy: current.isEnemy,
                    slot: current.slot,
                    transformCharge: updatedCharge,
                    transformThreshold: current.transformThreshold,
                    transformIntoID: current.transformIntoID,
                    isTransformed: current.isTransformed
                )
            }
            setStatusText("SYNC \(updatedCharge)/\(threshold)", for: attackerSide)
            return true
        }

        let templateMap = BattleDeckService.templateMap(from: catalog)
        guard let transformedTemplate = templateMap[transformIntoID] else { return false }

        updateCard(card.id, for: attackerSide) { current in
            BattleCard(
                id: current.id,
                templateID: transformedTemplate.id,
                title: transformedTemplate.title,
                subtitle: transformedTemplate.subtitle,
                power: max(
                    current.power + 700,
                    transformedTemplate.power + currentWaveIndex * 140 + currentEnemyIndex * 110
                ),
                role: transformedTemplate.role,
                rarity: transformedTemplate.rarity,
                energyCost: transformedTemplate.energyCost,
                accentColor: current.accentColor,
                frameColor: current.frameColor,
                artworkName: transformedTemplate.artworkName ?? current.artworkName,
                skillText: transformedTemplate.skillText,
                ultimateText: transformedTemplate.ultimateText,
                isEnemy: current.isEnemy,
                slot: current.slot,
                transformCharge: threshold,
                transformThreshold: nil,
                transformIntoID: nil,
                isTransformed: true
            )
        }
        setStatusText("TRANSFORM SHIFT", for: attackerSide)
        lastActionText = "\(attackerSide == playerSide ? "PLAYER" : "ENEMY") \(transformedTemplate.title.uppercased())  •  AWAKENED"
        transformationShowcase = TransformationShowcase(
            title: transformedTemplate.title,
            subtitle: transformedTemplate.subtitle,
            artworkName: transformedTemplate.artworkName ?? card.artworkName,
            rarity: transformedTemplate.rarity,
            accentColor: card.accentColor,
            frameColor: card.frameColor,
            side: attackerSide
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            if self.transformationShowcase?.title == transformedTemplate.title {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.transformationShowcase = nil
                }
            }
        }
        return true
    }

    private func transformChargeGain(for card: BattleCard, effect: CardEffectPayload) -> Int {
        var gain = 1
        if card.role == .booster {
            gain += 1
        }
        if effect.isUltimate {
            gain += 1
        }
        if card.rarity == .legendary {
            gain += 1
        }
        return gain
    }

    private func updateCard(
        _ cardID: BattleCard.ID,
        for side: FighterSide,
        transform: (BattleCard) -> BattleCard
    ) {
        if side == playerSide {
            guard let index = playerCards.firstIndex(where: { $0.id == cardID }) else { return }
            playerCards[index] = transform(playerCards[index])
            if selectedPlayerCardID == cardID {
                selectedPlayerCardID = playerCards[index].id
            }
        } else {
            guard let index = enemyCards.firstIndex(where: { $0.id == cardID }) else { return }
            enemyCards[index] = transform(enemyCards[index])
        }
    }

    private func effectPayload(
        for card: BattleCard,
        attackerSide: FighterSide,
        targetSide: FighterSide
    ) -> CardEffectPayload {
        let rarityBonus: CGFloat = {
            switch card.rarity {
            case .common:
                return 0
            case .rare:
                return 0.05
            case .epic:
                return 0.1
            case .legendary:
                return 0.18
            }
        }()

        let currentBoostStacks = boostStacks(for: attackerSide)
        let boostMultiplier = CGFloat(currentBoostStacks) * 0.18
        let attackerShield = shield(for: attackerSide)
        let targetShield = shield(for: targetSide)

        let baseEffect: CardEffectPayload = {
            switch card.role {
            case .attacker:
                setBoostStacks(0, for: attackerSide)
                return CardEffectPayload(
                    damageMultiplier: 1.18 + rarityBonus + boostMultiplier,
                    bonusDamage: 0,
                    shieldGain: 0,
                    boostGain: 0,
                    energyGain: 0,
                    stripBoost: false,
                    shieldPierce: 0,
                    isUltimate: false,
                    actionSuffix: currentBoostStacks > 0 ? "BOOST BREAK" : "FINISHER"
                )
            case .booster:
                return CardEffectPayload(
                    damageMultiplier: 0.88 + rarityBonus + boostMultiplier * 0.45,
                    bonusDamage: 0,
                    shieldGain: 0,
                    boostGain: 1 + (card.rarity == .legendary ? 1 : 0),
                    energyGain: card.rarity == .common ? 1 : 2,
                    stripBoost: false,
                    shieldPierce: 0,
                    isUltimate: false,
                    actionSuffix: "TEAM BOOST"
                )
            case .guardUnit:
                return CardEffectPayload(
                    damageMultiplier: 0.95 + rarityBonus,
                    bonusDamage: 0,
                    shieldGain: 0.12 + rarityBonus * 0.6,
                    boostGain: 0,
                    energyGain: 1,
                    stripBoost: boostStacks(for: targetSide) > 0,
                    shieldPierce: 0,
                    isUltimate: false,
                    actionSuffix: "BARRIER UP"
                )
            }
        }()

        let attackerEnergy = attackerSide == playerSide ? playerEnergy : enemyEnergy
        let targetHealth = health(for: targetSide)
        switch card.templateID {
        case "kenji_rush":
            let isUltimate = currentBoostStacks >= 2
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier + (isUltimate ? 0.4 : currentBoostStacks > 0 ? 0.22 : 0.08),
                bonusDamage: baseEffect.bonusDamage + (isUltimate ? 0.05 : currentBoostStacks > 0 ? 0.02 : 0),
                shieldGain: baseEffect.shieldGain,
                boostGain: baseEffect.boostGain,
                energyGain: baseEffect.energyGain + (isUltimate ? 2 : currentBoostStacks > 0 ? 1 : 0),
                stripBoost: baseEffect.stripBoost,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: isUltimate,
                actionSuffix: isUltimate ? "DOJO CATACLYSM" : currentBoostStacks > 0 ? "RUSH CHAIN" : "OPENING RUSH"
            )
        case "kenji_guard":
            let isUltimate = attackerShield >= 0.16
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier + (isUltimate ? 0.24 : attackerShield > 0 ? 0.12 : 0.04),
                bonusDamage: baseEffect.bonusDamage + (isUltimate ? 0.035 : attackerShield > 0 ? 0.025 : 0),
                shieldGain: baseEffect.shieldGain + (isUltimate ? 0.14 : attackerShield > 0 ? 0.1 : 0.05),
                boostGain: baseEffect.boostGain,
                energyGain: baseEffect.energyGain + (isUltimate ? 1 : 0),
                stripBoost: true,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: isUltimate,
                actionSuffix: isUltimate ? "STEEL MIRROR" : attackerShield > 0 ? "IRON COUNTER" : "COUNTER WALL"
            )
        case "kenji_focus":
            let isUltimate = attackerEnergy >= maxEnergy - 1
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier + (isUltimate ? 0.18 : 0.08),
                bonusDamage: baseEffect.bonusDamage,
                shieldGain: baseEffect.shieldGain,
                boostGain: baseEffect.boostGain + (isUltimate ? 2 : 1),
                energyGain: baseEffect.energyGain + (isUltimate ? 2 : 1),
                stripBoost: baseEffect.stripBoost,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: isUltimate,
                actionSuffix: isUltimate ? "HEAVEN SPLITTER" : "DRAGON CHARGE"
            )
        case "freeza_beam":
            let isUltimate = targetHealth <= 0.4
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier + (isUltimate ? 0.32 : targetShield > 0 ? 0.1 : 0.04),
                bonusDamage: baseEffect.bonusDamage + (isUltimate ? 0.04 : 0),
                shieldGain: baseEffect.shieldGain,
                boostGain: baseEffect.boostGain,
                energyGain: baseEffect.energyGain,
                stripBoost: baseEffect.stripBoost,
                shieldPierce: max(baseEffect.shieldPierce, isUltimate ? 0.55 : targetShield > 0 ? 0.32 : 0.12),
                isUltimate: isUltimate,
                actionSuffix: isUltimate ? "EXECUTION RAY" : targetShield > 0 ? "DEATH PIERCE" : "EXECUTION LINE"
            )
        case "freeza_shell":
            let isUltimate = boostStacks(for: targetSide) >= 2
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier + (isUltimate ? 0.16 : 0.05),
                bonusDamage: baseEffect.bonusDamage,
                shieldGain: baseEffect.shieldGain + (isUltimate ? 0.14 : 0.08),
                boostGain: baseEffect.boostGain,
                energyGain: baseEffect.energyGain + (isUltimate ? 1 : 0),
                stripBoost: true,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: isUltimate,
                actionSuffix: isUltimate ? "TYRANT GUARD" : "COLD LOCK"
            )
        case "freeza_core":
            let isUltimate = currentBoostStacks >= 2 || attackerEnergy >= maxEnergy - 1
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier + (isUltimate ? 0.34 : 0.14) + CGFloat(currentBoostStacks) * 0.06,
                bonusDamage: baseEffect.bonusDamage + (isUltimate ? 0.05 : 0.015),
                shieldGain: baseEffect.shieldGain,
                boostGain: baseEffect.boostGain + (isUltimate ? 2 : 1),
                energyGain: baseEffect.energyGain + (isUltimate ? 2 : 1),
                stripBoost: baseEffect.stripBoost,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: isUltimate,
                actionSuffix: isUltimate ? "ABSOLUTE DOMINION" : "TYRANT ENGINE"
            )
        case "default_striker":
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier,
                bonusDamage: baseEffect.bonusDamage,
                shieldGain: baseEffect.shieldGain,
                boostGain: baseEffect.boostGain,
                energyGain: baseEffect.energyGain + (targetShield == 0 ? 1 : 0),
                stripBoost: baseEffect.stripBoost,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: false,
                actionSuffix: targetShield == 0 ? "OPEN LINE" : baseEffect.actionSuffix
            )
        case "default_guard":
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier,
                bonusDamage: baseEffect.bonusDamage,
                shieldGain: baseEffect.shieldGain + 0.04,
                boostGain: baseEffect.boostGain,
                energyGain: baseEffect.energyGain,
                stripBoost: baseEffect.stripBoost,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: false,
                actionSuffix: "FORTIFY"
            )
        case "default_boost":
            return CardEffectPayload(
                damageMultiplier: baseEffect.damageMultiplier,
                bonusDamage: baseEffect.bonusDamage,
                shieldGain: baseEffect.shieldGain,
                boostGain: baseEffect.boostGain + 1,
                energyGain: baseEffect.energyGain,
                stripBoost: baseEffect.stripBoost,
                shieldPierce: baseEffect.shieldPierce,
                isUltimate: false,
                actionSuffix: "SURGE CHAIN"
            )
        default:
            return baseEffect
        }
    }

    private func applyEffectPayload(
        _ effect: CardEffectPayload,
        attackerSide: FighterSide,
        targetSide: FighterSide
    ) {
        if effect.shieldGain > 0 {
            addShield(effect.shieldGain, for: attackerSide)
        }

        if effect.boostGain > 0 {
            addBoostStacks(effect.boostGain, for: attackerSide)
        }

        if effect.energyGain > 0 {
            gainEnergy(effect.energyGain, for: attackerSide)
        }

        if effect.stripBoost {
            setBoostStacks(0, for: targetSide)
            setStatusText("BOOST JAMMED", for: targetSide)
        }

        if effect.shieldPierce > 0, shield(for: targetSide) > 0 {
            setStatusText("SHIELD PIERCED", for: targetSide)
        }

        if effect.isUltimate {
            setStatusText("ULT READY", for: attackerSide)
        }
    }

    private func consumeShield(for side: FighterSide, incomingDamage: CGFloat, shieldPierce: CGFloat = 0) -> CGFloat {
        let currentShield = shield(for: side)
        let clampedPierce = min(0.75, max(0, shieldPierce))
        guard currentShield > 0 else { return incomingDamage }

        let piercedDamage = incomingDamage * clampedPierce
        let shieldableDamage = max(0, incomingDamage - piercedDamage)

        let absorbed = min(currentShield, shieldableDamage)
        let remaining = max(0, shieldableDamage - absorbed) + piercedDamage
        setShield(max(0, currentShield - absorbed), for: side)
        if remaining == 0, piercedDamage == 0 {
            setStatusText("SHIELD HOLD", for: side)
        }
        return remaining
    }

    private func shield(for side: FighterSide) -> CGFloat {
        side == playerSide ? playerShield : enemyShield
    }

    private func setShield(_ value: CGFloat, for side: FighterSide) {
        let clamped = min(0.5, max(0, value))
        if side == playerSide {
            playerShield = clamped
        } else {
            enemyShield = clamped
        }
    }

    private func addShield(_ value: CGFloat, for side: FighterSide) {
        setShield(shield(for: side) + value, for: side)
        setStatusText("SHIELD +\(Int((value * 100).rounded()))", for: side)
    }

    private func boostStacks(for side: FighterSide) -> Int {
        side == playerSide ? playerBoostStacks : enemyBoostStacks
    }

    private func setBoostStacks(_ value: Int, for side: FighterSide) {
        let clamped = min(3, max(0, value))
        if side == playerSide {
            playerBoostStacks = clamped
        } else {
            enemyBoostStacks = clamped
        }
        if clamped == 0 {
            setStatusText("NEUTRAL", for: side)
        }
    }

    private func addBoostStacks(_ value: Int, for side: FighterSide) {
        let updated = boostStacks(for: side) + value
        setBoostStacks(updated, for: side)
        setStatusText("BOOST x\(boostStacks(for: side))", for: side)
    }

    private func gainEnergy(_ value: Int, for side: FighterSide) {
        if side == playerSide {
            playerEnergy = min(maxEnergy, playerEnergy + value)
            setStatusText("KI +\(value)", for: side)
        } else {
            enemyEnergy = min(maxEnergy, enemyEnergy + value)
            setStatusText("KI +\(value)", for: side)
        }
    }

    private func setStatusText(_ text: String, for side: FighterSide) {
        if side == playerSide {
            playerStatusText = text
        } else {
            enemyStatusText = text
        }
    }

    private func highlight(cardID: BattleCard.ID, for side: FighterSide) {
        if side == playerSide {
            highlightedPlayerCardID = cardID
            highlightedEnemyCardID = enemyCards.first?.id
        } else {
            highlightedEnemyCardID = cardID
            highlightedPlayerCardID = playerCards.first?.id
        }
    }

    private func clearHighlights() {
        highlightedPlayerCardID = nil
        highlightedEnemyCardID = nil
    }
}
