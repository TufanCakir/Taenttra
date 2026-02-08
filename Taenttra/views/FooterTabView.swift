//
//  FooterTabView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct FooterTabView: View {

    @State private var selectedTab = 0
    @State private var showMenu = false

    private let buttons: [HomeButton] =
        Bundle.main.decode("homeButtons.json")

    var body: some View {
        ZStack {

            TabView(selection: $selectedTab) {

                NavigationStack { HomeView() }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)

                NavigationStack { UpgradeView() }
                    .tabItem {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Upgrade")
                    }
                    .tag(1)

                NavigationStack { ArtefactView() }
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Artefact")
                    }
                    .tag(2)

                NavigationStack { CrystalShopView() }
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Shop")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    FooterTabView()
        .environmentObject(CoinManager.shared)
        .environmentObject(UpgradeManager.shared)
}
