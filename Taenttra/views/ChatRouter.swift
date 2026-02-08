//
//  ChatRouter.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

@MainActor
struct ChatRouter: View {

    @EnvironmentObject var store: ChatStore

    var body: some View {
        Group {
            if store.activeChat != nil {
                ChattView()   // 👈 KEIN Parameter
            } else {
                EmptyChatPlaceholder()
            }
        }
        .task {
            print("🟣 ChatRouter render | activeID:",
                  store.activeID as Any,
                  "| activeChat:",
                  store.activeChat != nil)
        }
    }
}
