//
//  GlobalChrome.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import Combine
import Foundation

final class GlobalChromeState: ObservableObject {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
}
