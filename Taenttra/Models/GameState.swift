//
//  GameState.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation
import Combine

class GameState: ObservableObject {

    // MARK: - Progress
    @Published private(set) var completedLevels: Set<String> = []
    @Published private(set) var completedIslands: Set<String> = []
    @Published private(set) var unlockedStageId: Int = 1

    // MARK: - Level Unlock
    func isLevelUnlocked(_ level: Level) -> Bool {
        guard let required = level.unlockAfter else { return true }
        return completedLevels.contains(required)
    }

    // MARK: - Island Unlock
    func isIslandUnlocked(
        _ island: Island,
        in dimension: Dimension
    ) -> Bool {

        let stageId = stageId(for: island, in: dimension)

        // Stage-Lock
        guard stageId <= unlockedStageId else {
            return false
        }

        // Unlock-Chain (unlockAfterIslandId)
        guard let required = island.unlockAfterIslandId else {
            return true
        }

        return completedIslands.contains(required)
    }

    // MARK: - Complete Level
    func completeLevel(
        _ level: Level,
        in island: Island,
        dimension: Dimension
    ) {
        completedLevels.insert(level.id)
        checkIslandCompletion(island, in: dimension)
    }

    // MARK: - Island Completion
    private func checkIslandCompletion(
        _ island: Island,
        in dimension: Dimension
    ) {

        let allCompleted = island.levels.allSatisfy {
            completedLevels.contains($0.id)
        }

        if allCompleted {
            completedIslands.insert(island.id)

            let stageId = stageId(for: island, in: dimension)
            checkStageCompletion(stageId: stageId, in: dimension)
        }
    }

    // MARK: - Stage Completion
    private func checkStageCompletion(
        stageId: Int,
        in dimension: Dimension
    ) {

        guard let stage = dimension.stages.first(where: { $0.id == stageId }) else {
            return
        }

        let allCompleted = stage.islandIds.allSatisfy {
            completedIslands.contains($0)
        }

        if allCompleted {
            unlockedStageId = max(unlockedStageId, stageId + 1)
        }
    }

    // MARK: - Helper
    private func stageId(
        for island: Island,
        in dimension: Dimension
    ) -> Int {

        dimension.stages
            .first(where: { $0.islandIds.contains(island.id) })?
            .id ?? 1
    }
}
