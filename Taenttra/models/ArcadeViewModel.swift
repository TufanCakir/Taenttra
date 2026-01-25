//
//  ArcadeViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation
import Combine

final class ArcadeViewModel: ObservableObject {

    @Published var stages: [ArcadeStage] = []
    @Published var selectedStage: ArcadeStage?

    init() {
        stages = ArcadeLoader.load().stages
    }

    func select(_ stage: ArcadeStage) {
        selectedStage = stage
    }
}

