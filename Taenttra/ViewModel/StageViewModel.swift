//
//  StageViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation
import Combine

class StageViewModel: ObservableObject {

    // MARK: - Progress
    @Published private(set) var completedLevels: Set<String> = []
    @Published private(set) var completedIslands: Set<String> = []
    @Published private(set) var unlockedWorldStage: Int = 1

    // MARK: - Stage ID Helper
    private func stageId(for island: Island, in dimension: Dimension) -> Int {
        dimension.stages
            .first(where: { $0.islandIds.contains(island.id) })?
            .id ?? 1
    }

    // MARK: - Current Unlocked Stage
    func currentUnlockedStage(in dimension: Dimension) -> Int {
        unlockedWorldStage
    }

    // MARK: - Level Unlock
    func isLevelUnlocked(_ level: Level) -> Bool {
        guard let required = level.unlockAfter else {
            return true
        }
        return completedLevels.contains(required)
    }

    // MARK: - Island Unlock
    func isIslandUnlocked(_ island: Island, in dimension: Dimension) -> Bool {

        // Stage-Lock
        let islandStage = stageId(for: island, in: dimension)
        guard islandStage <= unlockedWorldStage else {
            return false
        }

        // Progress-Lock
        guard let required = island.unlockAfterIslandId else {
            return true
        }

        return completedIslands.contains(required)
    }

    // MARK: - Complete Level
    func completeLevel(
        _ level: Level,
        on island: Island,
        in dimension: Dimension
    ) {
        completedLevels.insert(level.id)

        checkIslandCompletion(island, in: dimension)
    }

    // MARK: - Check Island Completion
    private func checkIslandCompletion(
        _ island: Island,
        in dimension: Dimension
    ) {
        let allCompleted = island.levels.allSatisfy {
            completedLevels.contains($0.id)
        }

        if allCompleted {
            completedIslands.insert(island.id)

            let islandStage = stageId(for: island, in: dimension)
            checkStageCompletion(stageId: islandStage, in: dimension)
        }
    }

    // MARK: - Check Stage Completion
    private func checkStageCompletion(
        stageId: Int,
        in dimension: Dimension
    ) {
        guard let stage = dimension.stages.first(where: { $0.id == stageId }) else { return }

        let allCompleted = stage.islandIds.allSatisfy {
            completedIslands.contains($0)
        }

        if allCompleted {
            unlockedWorldStage = max(unlockedWorldStage, stageId + 1)
        }
    }
}
