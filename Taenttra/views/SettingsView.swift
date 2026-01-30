//
//  SettingsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject private var audio = AudioManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // 🎵 AUDIO
                sectionCard(title: "AUDIO") {

                    Toggle(
                        "Music",
                        isOn: Binding(
                            get: { audio.musicEnabled },
                            set: { audio.setEnabled($0) }
                        )
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("VOLUME")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Slider(
                            value: Binding(
                                get: { Double(audio.volume) },
                                set: { audio.volume = Float($0) }
                            ),
                            in: 0...1
                        )
                    }
                }

                // ℹ️ ABOUT
                sectionCard(title: "ABOUT") {
                    infoRow("Game", "Taenttra")
                    infoRow("Version", appVersion)
                    infoRow("Build", appBuild)
                    infoRow("Developer", "Tufan Cakir")
                }

                // 📄 INFO
                sectionCard(title: "INFO") {

                    navigationRow("Credits") {
                        CreditsView()
                    }

                    navigationRow("Licenses") {
                        LicensesView()
                    }
                }

                // ⚙️ SYSTEM
                sectionCard(title: "SYSTEM") {
                    infoRow("Platform", platformName)
                    infoRow("OS Version", osVersion)
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color.black.opacity(0.03))
        .navigationTitle("Options")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - UI Helpers

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 14) {

            Text(title)
                .font(.headline.weight(.bold))

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.body)
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
                Spacer()
                Text("›")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
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
