//
//  RootView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct RootView: View {

    @StateObject private var navigation = NavigationState()

    var body: some View {
        
        VStack(spacing: 0) {

            ZStack {
                switch navigation.currentRoute {
                case .home:
                    HomeView()
                case .team:
                    TeamView()
                case .summon:
                    SummonView()
                case .shop:
                    ShopView()
                case .exchange:
                    ExchangeView()
                }
            }
        }
        .environmentObject(navigation)
    }
}
