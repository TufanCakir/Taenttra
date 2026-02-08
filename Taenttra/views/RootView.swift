//
//  RootView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

struct RootView: View {

    @StateObject private var chatStore = ChatStore()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {
                ChatRouter()
            }
            .tabItem {
                Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(0)

            NavigationStack {
                Sidebar(
                    store: chatStore,
                    onOpenChat: {
                        selectedTab = 0
                    }
                )
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(1)

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
            .tag(2)
        }
        .environmentObject(chatStore)   // ✅ EINZIGE Quelle der Wahrheit
    }
}
