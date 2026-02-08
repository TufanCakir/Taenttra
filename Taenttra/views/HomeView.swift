//
//  HomeView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var bgManager: BackgroundManager
    @EnvironmentObject var musicManager: MusicManager

    @State private var showMenu = false

    // Buttons laden (JSON)
    private let buttons: [HomeButton] = Bundle.main.decode("homeButtons.json")

    var body: some View {
        ZStack {

            SpiritGridBackground(style: bgManager.selected)
                .allowsHitTesting(false)

            VStack {
                HeaderView()
                Spacer()
            }

            // 🔥 CENTER BUTTON
            VStack {
                Spacer()
                CenterActionButton {
                    withAnimation(
                        .spring(response: 0.45, dampingFraction: 0.85)
                    ) {
                        showMenu = true
                    }
                }
                .padding(.bottom, 32)
            }

            // 🔥 MENU SHEET (HIER KOMMT DIE TRANSITION HIN)
            if showMenu {
                HomeMenuSheet(
                    buttons: buttons,
                    close: {
                        withAnimation(
                            .spring(response: 0.45, dampingFraction: 0.85)
                        ) {
                            showMenu = false
                        }
                    }
                )
                .zIndex(10)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(
                            with: .opacity
                        ),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    )
                )
            }
        }
        .navigationBarHidden(true)
    }
}

struct CenterActionButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.black,
                                Color.blue,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.6), radius: 18)
                    .shadow(color: .black.opacity(0.6), radius: 10)

                Image(systemName: "circle.circle")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 100)
        }
        .buttonStyle(.plain)
    }
}

struct HomeMenuSheet: View {

    let buttons: [HomeButton]
    let close: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {
        ZStack {

            // 🌑 Backdrop
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.8),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture { close() }

            // 📦 Sheet
            VStack(spacing: 16) {

                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                // Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(buttons) { button in
                            NavigationLink {
                                ScreenFactory.shared.make(button.destination)
                            } label: {
                                HomeButtonView(button: button)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }

                // 🔥 GRADIENT CLOSE BUTTON
                GradientActionButton(icon: "xmark") {
                    close()
                }
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 520)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black.opacity(0.95))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(BackgroundManager.shared)
        .environmentObject(MusicManager.shared)
        .environmentObject(SpiritGameController())
        .environmentObject(CoinManager.shared)
        .environmentObject(CrystalManager.shared)
        .environmentObject(AccountLevelManager.shared)
        .environmentObject(ArtefactInventoryManager.shared)
        .environmentObject(EventShopManager.shared)
        .preferredColorScheme(.dark)
}
