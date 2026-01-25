//
//  GameScreen.swift
//  Taenttra
//
//  Created by Tufan Cakir on 24.01.26.
//

import Combine
import Foundation

enum GameScreen {
    case start
    case home
    case characterSelect
    case versus
    case arcade
}

final class GameState: ObservableObject {
    @Published var screen: GameScreen = .start

    @Published var leftCharacter: Character?
    @Published var rightCharacter: Character?

    @Published var currentStage: VersusStage?  // 🔥 NEU

    // 🔥 DAS ist die Quelle für Combat-State
    @Published var versusViewModel: VersusViewModel?

    @Published var leftHealth: CGFloat = 0
    @Published var rightHealth: CGFloat = 0
    @Published var time: Int = 99
}
