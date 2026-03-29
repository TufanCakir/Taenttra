//
//  RewardManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 29.03.26.
//

final class RewardManager {
    private enum Constants {
        static let xpPerCoinDivisor = 2
        static let xpPerLevelMultiplier = 100
    }

    static let shared = RewardManager()

    private init() {}

    func apply(
        rewards: VictoryRewards,
        to wallet: PlayerWallet
    ) {
        guard hasAnyReward(rewards) else { return }

        wallet.coins += rewards.coins
        wallet.crystals += rewards.crystals
        wallet.shards += rewards.shards
        wallet.xp += experienceGain(for: rewards)

        applyPendingLevelUps(to: wallet)
    }

    private func hasAnyReward(_ rewards: VictoryRewards) -> Bool {
        rewards.coins > 0 || rewards.crystals > 0 || rewards.shards > 0
    }

    private func experienceGain(for rewards: VictoryRewards) -> Int {
        max(0, rewards.coins / Constants.xpPerCoinDivisor)
    }

    private func applyPendingLevelUps(to wallet: PlayerWallet) {
        while wallet.xp >= requiredXP(for: wallet.level) {
            wallet.xp -= requiredXP(for: wallet.level)
            wallet.level += 1
        }
    }

    private func requiredXP(for level: Int) -> Int {
        max(1, level * Constants.xpPerLevelMultiplier)
    }
}
