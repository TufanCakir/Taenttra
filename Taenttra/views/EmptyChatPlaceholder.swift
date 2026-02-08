//
//  EmptyChatPlaceholder.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

struct EmptyChatPlaceholder: View {

    var body: some View {
        ContentUnavailableView(
            "Select a chat",
            systemImage: "bubble.left.and.bubble.right",
            description: Text("Choose a conversation to get started.")
        )
        .symbolRenderingMode(.hierarchical)
    }
}
