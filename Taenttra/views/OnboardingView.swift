//
//  OnboardingView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct OnboardingView: View {

    @AppStorage(AppStorageKeys.hasSeenOnboarding)
    private var hasSeenOnboarding: Bool = false

    var body: some View {
        TabView {
            OnboardingPage(
                title: "Willkommen in Taenttra",
                subtitle:
                    "Entdecke mystische Welten, mächtige Geister und epische Raids.",
                image: "sparkles"
            )

            OnboardingPage(
                title: "Geister & Artefakte",
                subtitle: "Sammle, verbessere und kombiniere sie strategisch.",
                image: "flame"
            )

            OnboardingPage(
                title: "Events & Raids",
                subtitle:
                    "Nimm an zeitlich begrenzten Events teil – wie dem Malphas Abyss Raid.",
                image: "bolt.fill"
            )

            VStack(spacing: 24) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)

                Text("Bereit?")
                    .font(.largeTitle.bold())

                Button {
                    hasSeenOnboarding = true
                } label: {
                    Text("Spiel starten")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
        }
        .tabViewStyle(.page)
    }
}
