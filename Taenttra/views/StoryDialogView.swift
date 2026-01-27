//
//  StoryDialogView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import SwiftUI

struct StoryDialogView: View {

    let dialog: StoryDialog
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(dialog.image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)

            Text(dialog.text)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()

            Button("Continue") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
