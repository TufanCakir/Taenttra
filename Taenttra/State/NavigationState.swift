//
//  NavigationState.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Combine

enum Route: String, Codable {
    case home
    case team
    case summon
    case shop
    case exchange
}

final class NavigationState: ObservableObject {
    @Published var currentRoute: Route = .home
}
