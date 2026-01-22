//
//  ModeRegistry.swift
//  Taenttara
//

import Foundation

enum ModeRegistry {

    static let all: [Mode] = {
        Bundle.main.loadKhioneModes()
    }()
}
