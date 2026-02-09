//
//  SettingsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Environment Objects
    @EnvironmentObject var bgManager: BackgroundManager
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var crystalManager: CrystalManager
    @EnvironmentObject var artefactInventoryManager: ArtefactInventoryManager
    @EnvironmentObject var accountManager: AccountLevelManager
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var spiritGame: SpiritGameController

    // MARK: - Local State
    @State private var showResetAlert = false
    @State private var showResetConfirmation = false
    @State private var resetAnimation = false

    private let appVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ?? "–"

    private let buildNumber =
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"

    private let iosVersion = UIDevice.current.systemVersion
    private let deviceModel = UIDevice.current.model

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                SpiritGridBackground(style: bgManager.selected)

                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {

                        // MARK: Audio
                        settingsSection(title: "Audio") {
                            VStack(spacing: 18) {
                                MusicToggleButton()
                                    .environmentObject(musicManager)

                                MusicVolumeSlider()
                                    .padding(.horizontal, 6)
                                    .opacity(musicManager.isMusicOn ? 1 : 0.35)
                                    .disabled(!musicManager.isMusicOn)
                                    .environmentObject(musicManager)
                            }
                        }

                        // MARK: Account
                        settingsSection(title: "Account Overview") {
                            HStack(spacing: 22) {
                                StatBox(
                                    icon: "star.fill",
                                    title: "Level",
                                    value: "\(accountManager.level)",
                                    color: Color(hex: "#32CD32")
                                )
                                StatBox(
                                    icon: "suit.diamond.fill",
                                    title: "Crystals",
                                    value: "\(crystalManager.crystals)",
                                    color: Color(hex: "#0096FF")
                                )
                                StatBox(
                                    icon: "circle.fill",
                                    title: "Coins",
                                    value: "\(coinManager.coins)",
                                    color: Color(hex: "#FFEA00")
                                )
                                StatBox(
                                    icon: "hexagon.fill",
                                    title: "Artefacts",
                                    value: "\(artefactInventoryManager.total)",
                                    color: Color(hex: "#00E5FF")
                                )

                            }
                            .frame(maxWidth: .infinity)

                        }

                        // MARK: - About
                        settingsSection(title: "About") {
                            VStack(spacing: 14) {

                                aboutRow(
                                    title: "App Version",
                                    value: "\(appVersion) (\(buildNumber))"
                                )

                                aboutRow(
                                    title: "iOS Version",
                                    value: "iOS \(iosVersion)"
                                )

                                aboutRow(
                                    title: "Device",
                                    value: deviceModel
                                )

                                Divider().opacity(0.3)

                                Link(
                                    destination: URL(
                                        string:
                                            "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
                                    )!
                                ) {
                                    Label(
                                        "Apple Terms of Service",
                                        systemImage: "doc.text"
                                    )
                                }
                                .foregroundColor(.cyan)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.35))
                                )
                            }
                        }

                        // MARK: Data & Storage
                        settingsSection(title: "Data & Storage") {
                            Button {
                                withAnimation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                ) {
                                    showResetAlert = true
                                }
                            } label: {
                                Label(
                                    "Reset All Progress",
                                    systemImage: "trash.fill"
                                )
                                .font(.title3.bold())
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(16)
                                .shadow(color: .red.opacity(0.5), radius: 6)

                            }
                            .padding(.horizontal, 8)
                            .shadow(color: .white, radius: 5)

                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("⚠️ Reset all progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { performReset() }
            } message: {
                Text(
                    "This will permanently delete your progress, characters, skins, and shop data."
                )
            }
            .overlay(resetConfirmationOverlay)
            .background(
                Color.black.opacity(0.25)  // 🔥 sehr wichtig
            )
        }
    }
}

// MARK: - Reset Confirmation Overlay
extension SettingsView {
    private var resetConfirmationOverlay: some View {
        Group {
            if showResetConfirmation {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .scaleEffect(resetAnimation ? 1.15 : 0.8)
                        .animation(.spring(), value: resetAnimation)

                    Text("Progress Reset")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: .white, radius: 5)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Reset Logic
extension SettingsView {
    private func performReset() {

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Economy
        coinManager.reset()
        crystalManager.reset()
        accountManager.reset()

        // Gameplay
        UpgradeManager.shared.reset()
        ArtefactInventoryManager.shared.reset()
        spiritGame.resetStats()

        // Event Shop
        EventShopManager.shared.reset()

        // Social / Daily
        DailyLoginManager.shared.reset()
        GiftManager.shared.reset()

        // Quests
        QuestManager.shared.reset()

        // Game Center
        GameCenterRewardService.shared.reset()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showResetConfirmation = true
            resetAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                showResetConfirmation = false
            }
        }

        print("🧩 ALL game systems successfully reset.")
    }
}

// MARK: - Section Wrapper Component
extension SettingsView {
    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            content()
        }
        .padding()
        .background(SettingsCardBackground())
    }
}

// MARK: - MusicToggleButton Component
struct MusicToggleButton: View {
    @EnvironmentObject var musicManager: MusicManager
    @State private var pulse = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                musicManager.toggleMusic()
                pulse.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                Image(
                    systemName: musicManager.isMusicOn
                        ? "music.note.list"
                        : "speaker.slash.fill"
                )
                .font(.title2.bold())
                .foregroundColor(musicManager.isMusicOn ? .cyan : .gray)
                .scaleEffect(pulse ? 1.15 : 1.0)

                Text(musicManager.isMusicOn ? "Music On" : "Music Off")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        musicManager.isMusicOn
                            ? Color.cyan.opacity(0.6)
                            : Color.white.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct SettingsCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.75),
                        Color.black.opacity(0.55),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: .black.opacity(0.6), radius: 12, y: 6)
    }
}

// MARK: - StatBox Component
private struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6).background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}

private func aboutRow(
    title: String,
    value: String
) -> some View {
    HStack {
        Text(title)
            .foregroundColor(.white.opacity(0.7))
        Spacer()
        Text(value)
            .fontWeight(.semibold)
            .foregroundColor(.white)
    }
    .font(.subheadline)
}

#Preview {
    SettingsView()
        .environmentObject(CoinManager.shared)
        .environmentObject(CrystalManager.shared)
        .environmentObject(ArtefactInventoryManager())
        .environmentObject(AccountLevelManager.shared)
        .environmentObject(MusicManager())
        .preferredColorScheme(.dark)
}
