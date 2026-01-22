//
//  ChatRouter.swift
//  Taenttra
//

import SwiftUI

@MainActor
struct ChatRouter: View {

    @ObservedObject var store: ChatStore

    var body: some View {
        NavigationStack {
            Group {
                if store.activeChat != nil {
                    KhioneView(chatStore: store)
                } else {
                    EmptyChatPlaceholder()
                }
            }
        }
    }
}
