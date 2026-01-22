//
//  OnboardingPage.swift
//  Taenttra
//

import SwiftUI

struct OnboardingPage: View {

    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            iconView

            VStack(spacing: 10) {
                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(text)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
}

extension OnboardingPage {

    fileprivate var iconView: some View {
        Image(systemName: icon)
            .font(.largeTitle)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.primary)
            .padding(24)
            .background(
                Circle()
                    .fill(.thinMaterial)
            )
            .accessibilityHidden(true)
    }
}
