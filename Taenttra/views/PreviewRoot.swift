//
//  PreviewRoot.swift
//  Taenttra
//

import SwiftUI

struct PreviewRoot<Content: View>: View {
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let theme = ThemeManager()

        content
            .environmentObject(theme)
    }
}
