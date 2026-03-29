//
//  TrainingViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Combine
import Foundation

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
