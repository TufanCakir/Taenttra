//
//  TrainingViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation
import Combine

final class TrainingViewModel: ObservableObject {

    @Published var modes: [TrainingMode] = []
    @Published var selectedMode: TrainingMode?

    init() {
        modes = TrainingLoader.load().modes
    }

    func select(_ mode: TrainingMode) {
        selectedMode = mode
    }
}

