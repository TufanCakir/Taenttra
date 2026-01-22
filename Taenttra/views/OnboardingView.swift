//
//  OnboardingView.swift
//  Taenttra
//

import SwiftUI

struct OnboardingView: View {

    var onFinish: () -> Void
    @State private var page = 0

    var body: some View {
        VStack {

            TabView(selection: $page) {

                OnboardingPage(
                    icon: "cpu",
                    title: "Taenttra",
                    text:
                        "On-device AI.\nFast. Private. Natural.\n\nRuns entirely on your iPhone.\nNo cloud. No servers.\nYour data stays with you."
                )
                .tag(0)

                OnboardingPage(
                    icon: "bolt.fill",
                    title: "Built for iOS",
                    text:
                        "Fully native with Swift and SwiftUI.\n\nDeep system integration makes Taenttra fast, responsive, and available via Siri and Spotlight."
                )
                .tag(1)

                OnboardingPage(
                    icon: "hand.raised.fill",
                    title: "Privacy & Accessibility",
                    text:
                        "Designed for privacy, accessibility, and simplicity.\n\nSpeech support and clear language make Taenttra easy for everyone."
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .animation(.easeInOut, value: page)

            Button(action: advance) {
                Text(page < 2 ? "Continue" : "Start using Taenttra")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 8)
        }
    }

    private func advance() {
        if page < 2 {
            page += 1
        } else {
            onFinish()
        }
    }
}
