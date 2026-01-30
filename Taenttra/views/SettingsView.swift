//
//  SettingsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject private var audio = AudioManager.shared
    @EnvironmentObject var gameState: GameState

    var body: some View {
        NavigationStack {  // 🔥 DAS FEHLT

            ZStack(alignment: .topLeading) {

                // 🌑 BASE
                Color.black.ignoresSafeArea()

                // ⬅️ GAME BACK BUTTON (HUD)
                GameBackButton {
                    gameState.goBack()
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                .zIndex(10)

                ScrollView {
                    VStack(spacing: 24) {

                        sectionCard(title: "AUDIO") {

                            Toggle(
                                "MUSIC",
                                isOn: Binding(
                                    get: { audio.musicEnabled },
                                    set: { audio.setEnabled($0) }
                                )
                            )
                            .toggleStyle(SwitchToggleStyle(tint: .cyan))

                            VStack(alignment: .leading, spacing: 8) {
                                Text("VOLUME")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.cyan.opacity(0.8))
                                    .tracking(1)

                                Slider(
                                    value: Binding(
                                        get: { Double(audio.volume) },
                                        set: { audio.volume = Float($0) }
                                    ),
                                    in: 0...1
                                )
                                .tint(.cyan)
                            }
                        }
                    }

                    sectionCard(title: "ABOUT") {
                        infoRow("GAME", "TAENTTRA")
                        infoRow("VERSION", appVersion)
                        infoRow("BUILD", appBuild)
                        infoRow("DEVELOPER", "TUFAN CAKIR")
                    }

                    sectionCard(title: "INFO") {
                        navigationRow("CREDITS") { CreditsView() }
                        navigationRow("LICENSES") { LicensesView() }
                    }

                    sectionCard(title: "SYSTEM") {
                        infoRow("PLATFORM", platformName.uppercased())
                        infoRow("OS", osVersion)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)  // 🔥 Platz für BackButton
            }
        }
    }

    // MARK: - UI

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .tracking(2)
                .foregroundColor(.cyan)

            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.5))
        }
        .font(.system(size: 14, weight: .medium))
    }

    private func navigationRow<Destination: View>(
        _ title: String,
        destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Text("›")
                    .foregroundColor(.cyan.opacity(0.6))
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - App Info

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var platformName: String {
        #if os(iOS)
            return "iOS"
        #elseif os(macOS)
            return "macOS"
        #else
            return "Unknown"
        #endif
    }

    private var osVersion: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
