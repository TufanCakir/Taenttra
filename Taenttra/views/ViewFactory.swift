//
//  ViewFactory.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

enum AppRoute {
    case account
}

@MainActor
struct ViewFactory {

    @ViewBuilder
    static func view(for route: AppRoute) -> some View {
        switch route {
        case .account:
            AccountView()
        }
    }
}
