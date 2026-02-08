//
//  OnboardingPage.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let image: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: image)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
