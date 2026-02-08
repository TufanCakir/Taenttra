//
//  ModeRegistry.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import Foundation

enum ModeRegistry {

    static let all: [Mode] = {
        Bundle.main.loadModes()
    }()
}
