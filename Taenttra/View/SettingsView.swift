//
//  SettingsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct SettingsView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let cardCornerRadius: CGFloat = 24
    }

    @ObservedObject private var audio = AudioManager.shared
    @EnvironmentObject var gameState: GameState

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                backgroundLayer

                GameBackButton {
                    gameState.goBack()
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                .zIndex(10)

                ScrollView {
                    VStack(spacing: 20) {
                        heroCard

                        sectionCard(
                            title: "AUDIO CONTROL",
                            accent: .cyan
                        ) {
                            audioToggle
                            volumeControl
                        }

                        sectionCard(
                            title: "ACCOUNT DATA",
                            accent: .orange
                        ) {
                            infoRow("GAME", "TAENTTRA")
                            infoRow("VERSION", appVersion)
                            infoRow("BUILD", appBuild)
                            infoRow("DEVELOPER", "TUFAN CAKIR")
                        }

                        sectionCard(
                            title: "SUPPORT",
                            accent: .pink
                        ) {
                            navigationRow("CREDITS") { CreditsView() }
                            navigationRow("LICENSES") { LicensesView() }
                        }

                        sectionCard(
                            title: "SYSTEM",
                            accent: .green
                        ) {
                            infoRow("PLATFORM", platformName.uppercased())
                            infoRow("OS", osVersion)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.top, 64)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.07),
                    Color(red: 0.05, green: 0.01, blue: 0.16),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 36)
                .offset(x: -120, y: -210)

            Circle()
                .fill(Color.pink.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 42)
                .offset(x: 140, y: 180)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.35),
                            Color.blue.opacity(0.2),
                            Color.black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    statusChip(title: "SYSTEM", color: .cyan)
                    Spacer()
                    statusChip(title: audio.musicEnabled ? "AUDIO ON" : "AUDIO OFF", color: audio.musicEnabled ? .green : .orange)
                }

                Spacer()

                Text("SETTINGS")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white)

                Text("Tune the battle atmosphere, review app details, and manage support info.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.leading)
            }
            .padding(22)
        }
        .frame(height: 190)
        .shadow(color: .cyan.opacity(0.18), radius: 20)
    }

    private var audioToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MUSIC")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.white)

                Text(audio.musicEnabled ? "Battle tracks and menu themes are enabled." : "Audio playback is currently muted.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { audio.musicEnabled },
                    set: { audio.setEnabled($0) }
                )
            )
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: .cyan))
        }
    }

    private var volumeControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VOLUME")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.cyan.opacity(0.9))

                Spacer()

                Text("\(Int(audio.volume * 100))%")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            Slider(
                value: Binding(
                    get: { Double(audio.volume) },
                    set: { audio.volume = Float($0) }
                ),
                in: 0...1
            )
            .tint(.cyan)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.32))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func sectionCard<Content: View>(
        title: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(accent)

                Spacer()

                Circle()
                    .fill(accent.opacity(0.9))
                    .frame(width: 8, height: 8)
            }

            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                        .stroke(accent.opacity(0.24), lineWidth: 1)
                )
        )
        .shadow(color: accent.opacity(0.12), radius: 12)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.62))
                .frame(width: 84, alignment: .leading)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 2)
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
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.cyan.opacity(0.72))
            }
            .padding(.vertical, 8)
        }
    }

    private func statusChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.6)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(color.opacity(0.22))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
    }

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
