//
//  WorldViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Combine
import Foundation

class WorldViewModel: ObservableObject {

    // MARK: - Published State
    @Published var world: WorldData?
    @Published var currentDimension: Dimension?
    @Published var selectedIsland: Island?

    // MARK: - Init
    init() {
        load()
    }

    // MARK: - Load JSON
    func load() {
        do {
            guard let url = Bundle.main.url(forResource: "world", withExtension: "json") else {
                print("❌ JSON nicht gefunden")
                return
            }

            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(WorldData.self, from: data)

            world = decoded
            currentDimension = decoded.dimensions.first

            print("✅ World geladen")

        } catch {
            print("❌ DECODE ERROR:", error)
        }
    }

    // MARK: - Switch Dimension
    func switchDimension(to id: String) {
        currentDimension = world?.dimensions.first(where: { $0.id == id })
        selectedIsland = nil
    }

    // MARK: - All Islands
    var islands: [Island] {
        currentDimension?.islands ?? []
    }

    // MARK: - All Stages
    var stages: [Stage] {
        currentDimension?.stages.sorted(by: { $0.id < $1.id }) ?? []
    }

    // MARK: - Islands for Stage
    func islands(for stage: Stage) -> [Island] {
        guard let dimension = currentDimension else { return [] }

        return dimension.islands.filter {
            stage.islandIds.contains($0.id)
        }
    }

    // MARK: - Stage for Island
    func stageId(for island: Island) -> Int? {
        currentDimension?.stages.first {
            $0.islandIds.contains(island.id)
        }?.id
    }
}
