//
//  SlantDirection.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

enum SlantDirection {
    case left
    case right
}

struct GameHUDModel {
    let leftName: String
    let rightName: String
    let leftHealth: CGFloat
    let rightHealth: CGFloat
    let time: Int
}
