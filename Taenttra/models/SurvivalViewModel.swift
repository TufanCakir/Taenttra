//
//  SurvivalViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Foundation
import Combine

final class SurvivalViewModel: ObservableObject {

    @Published var modes: [SurvivalMode] = []
    @Published var selectedMode: SurvivalMode?

    init() {
        modes = SurvivalLoader.load().modes
    }

    func select(_ mode: SurvivalMode) {
        selectedMode = mode
    }
}

