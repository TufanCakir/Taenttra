//
//  RootView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct RootView: View {
    private struct FooterTab: Identifiable {
        let item: HomeMenuItem
        let systemName: String

        var id: HomeMenuItem { item }
    }

    private struct FooterPage: Identifiable {
        let featuredItem: HomeMenuItem
        let tabs: [FooterTab]

        var id: HomeMenuItem { featuredItem }
    }

    private enum Layout {
        static let topPlateCornerRadius: CGFloat = 18
        static let topSegmentCornerRadius: CGFloat = 10
        static let footerButtonSize: CGFloat = 60
    }

    @EnvironmentObject var gameState: GameState
    @StateObject private var globalChrome = GlobalChromeState()
    @State private var footerPageIndex = 0

    private let footerPages: [FooterPage] = [
        FooterPage(
            featuredItem: .summon,
            tabs: [
                FooterTab(item: .story, systemName: "book.closed.fill"),
                FooterTab(item: .shop, systemName: "cart.fill"),
                FooterTab(item: .summon, systemName: "sparkles.rectangle.stack.fill"),
                FooterTab(item: .skin, systemName: "sparkles"),
            ]
        ),
        FooterPage(
            featuredItem: .arcade,
            tabs: [
                FooterTab(item: .training, systemName: "figure.martial.arts"),
                FooterTab(item: .arcade, systemName: "bolt.fill"),
                FooterTab(item: .events, systemName: "flag.checkered.2.crossed"),
                FooterTab(item: .survival, systemName: "flame.fill"),
            ]
        ),
        FooterPage(
            featuredItem: .options,
            tabs: [
                FooterTab(item: .story, systemName: "book.closed.fill"),
                FooterTab(item: .options, systemName: "gearshape.fill"),
                FooterTab(item: .shop, systemName: "cart.fill"),
                FooterTab(item: .skin, systemName: "sparkles"),
            ]
        ),
    ]

    var body: some View {
        ZStack {
            AppBackgroundView(theme: activeTheme)
                .ignoresSafeArea()

            GameView()
                .environmentObject(globalChrome)
                .onAppear {
                    syncFooterPageWithCurrentScreen()
                }
                .onChange(of: gameState.screen) { _, _ in
                    syncFooterPageWithCurrentScreen()
                }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            globalHeader
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            globalFooter
        }
    }

    private var activeTheme: BackgroundTheme {
        BackgroundThemeService.theme(for: gameState.wallet?.selectedBackgroundThemeID)
    }

    private var globalHeader: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.19, blue: 0.28).opacity(0.98),
                    Color(red: 0.06, green: 0.08, blue: 0.14).opacity(0.98),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }

            HStack(spacing: 10) {
                compactCurrencyPlate(
                    icon: "icon_coin",
                    value: gameState.wallet?.coins ?? 0,
                    accent: Color(red: 0.99, green: 0.81, blue: 0.2)
                )

                metallicMemberPlate

                HStack(spacing: 6) {
                    compactCurrencyPlate(
                        icon: "icon_shard",
                        value: gameState.wallet?.shards ?? 0,
                        accent: .orange
                    )

                    compactCurrencyPlate(
                        icon: "icon_crystal",
                        value: gameState.wallet?.crystals ?? 0,
                        accent: .cyan
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 8)

            if gameState.showsBackButton {
                rootBackButton
                    .padding(.leading, 18)
                    .offset(y: 2)
            }
        }
    }

    private func compactCurrencyPlate(
        icon: String,
        value: Int,
        accent: Color
    ) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .shadow(color: accent.opacity(0.5), radius: 5)

            Text("\(value)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: Layout.topSegmentCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.16),
                            Color.black.opacity(0.28),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.topSegmentCornerRadius)
                        .stroke(accent.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private var metallicMemberPlate: some View {
        VStack(spacing: 2) {
            Text("Member457v")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(.white)

            Text(screenTitle)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.58))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Layout.topPlateCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.24),
                            Color(red: 0.32, green: 0.35, blue: 0.43).opacity(0.9),
                            Color.black.opacity(0.18),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.topPlateCornerRadius)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: .white.opacity(0.08), radius: 6, y: 2)
    }

    private var rootBackButton: some View {
        Button {
            gameState.goBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.58))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .shadow(color: .white.opacity(0.12), radius: 6)
    }

    private var globalFooter: some View {
        let currentPage = footerPages[footerPageIndex]

        return ZStack {
            footerBackground

            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    footerArrowButton(systemName: "chevron.left", direction: -1)

                    HStack(alignment: .bottom, spacing: 12) {
                        footerHomeButton

                        ForEach(currentPage.tabs) { tab in
                            footerTabButton(tab)
                        }
                    }

                    footerArrowButton(systemName: "chevron.right", direction: 1)
                }

                footerPagerDots
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
    }

    private var footerBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.03, blue: 0.08).opacity(0.98),
                    Color.black.opacity(0.98),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 28)
                .offset(y: -22)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 140, height: 140)
                .blur(radius: 18)
                .offset(y: -18)
        }
    }

    private func footerArrowButton(systemName: String, direction: Int) -> some View {
        let targetIndex = wrappedPageIndex(from: footerPageIndex, delta: direction)
        let targetTitle = footerPages[targetIndex].featuredItem.title.uppercased()

        return Button {
            shiftFooterPage(by: direction)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.yellow)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                Circle()
                                    .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
                            )
                    )
                    .shadow(color: .yellow.opacity(0.18), radius: 6)

                Text(targetTitle)
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.yellow.opacity(0.84))
                    .lineLimit(1)
                    .frame(width: 44)
            }
        }
        .buttonStyle(.plain)
    }

    private var footerPagerDots: some View {
        HStack(spacing: 6) {
            ForEach(footerPages.indices, id: \.self) { index in
                Button {
                    footerPageIndex = index
                } label: {
                    Capsule()
                        .fill(index == activePageIndex ? Color.yellow : Color.white.opacity(0.18))
                        .frame(width: index == activePageIndex ? 18 : 6, height: 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 2)
    }

    private var footerHomeButton: some View {
        let selected = isHomeSelected

        return Button {
            navigateHome()
        } label: {
            footerIconButton(
                title: "HOME",
                systemName: "house.fill",
                accent: selected ? .orange : .white.opacity(0.82),
                isSelected: selected
            )
        }
        .buttonStyle(.plain)
    }

    private func footerTabButton(_ tab: FooterTab) -> some View {
        let isLocked = isLocked(tab.item)
        let isSelected = gameState.screen == tab.item.screen

        return Button {
            guard !isLocked else { return }
            navigate(to: tab.item)
        } label: {
            if tab.item == footerPages[footerPageIndex].featuredItem {
                centerActionButton(
                    title: tab.item.title.uppercased(),
                    systemName: tab.systemName,
                    accent: isLocked ? .gray : tab.item.color,
                    isSelected: isSelected
                )
            } else {
                footerIconButton(
                    title: tab.item.title.uppercased(),
                    systemName: tab.systemName,
                    accent: isLocked ? .white.opacity(0.45) : (isSelected ? tab.item.color : .white.opacity(0.82)),
                    isSelected: isSelected
                )
            }
        }
        .disabled(isLocked)
        .opacity(isLocked ? 0.5 : 1)
        .buttonStyle(.plain)
    }

    private func footerIconButton(
        title: String,
        systemName: String,
        accent: Color,
        isSelected: Bool
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [accent.opacity(0.95), accent.opacity(0.55)]
                                : [Color.white.opacity(0.18), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color.white.opacity(0.28) : Color.white.opacity(0.12),
                                lineWidth: 1
                            )
                    )

                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(isSelected ? Color.black : .white)
            }
            .frame(width: Layout.footerButtonSize, height: Layout.footerButtonSize)

            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(isSelected ? accent : .white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
    }

    private func centerActionButton(
        title: String,
        systemName: String,
        accent: Color,
        isSelected: Bool
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.96),
                                accent.opacity(0.95),
                                accent.opacity(0.58),
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 44
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.34), lineWidth: 3)
                    )
                    .shadow(color: accent.opacity(0.45), radius: 14, y: 6)

                VStack(spacing: 2) {
                    Image(systemName: systemName)
                        .font(.system(size: 15, weight: .black))
                    Text(title)
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .tracking(1)
                }
                .foregroundStyle(.black.opacity(0.84))
            }
            .frame(width: 76, height: 76)
            .offset(y: -8)

            Capsule()
                .fill(isSelected ? accent.opacity(0.9) : Color.white.opacity(0.12))
                .frame(width: 24, height: 5)
        }
        .frame(maxWidth: .infinity)
    }

    private var activePageIndex: Int {
        footerPageIndex
    }

    private var isHomeSelected: Bool {
        gameState.screen == .home || gameState.screen == .start
    }

    private var screenTitle: String {
        switch gameState.screen {
        case .start: "START"
        case .home: "HOME"
        case .characterSelect: "SELECT"
        case .versus: "VERSUS"
        case .arcade: "ARCADE"
        case .story: "STORY"
        case .survival: "SURVIVAL"
        case .training: "TRAINING"
        case .events: "EVENTS"
        case .summon: "SUMMON"
        case .season: "SEASON"
        case .missiona: "MISSIONS"
        case .exchange: "EXCHANGE"
        case .gift: "GIFT"
        case .daily: "DAILY"
        case .options: "SETTINGS"
        case .shop: "SHOP"
        case .backgrounds: "BACKGROUNDS"
        case .skin: "SKINS"
        case .cards: "CARDS"
        }
    }

    private func navigateHome() {
        gameState.pendingMode = nil
        gameState.screen = .home
    }

    private func navigate(to item: HomeMenuItem) {
        gameState.pendingMode = nil
        gameState.screen = item.screen
    }

    private func isLocked(_ item: HomeMenuItem) -> Bool {
        guard let requiredScreen = requiredUnlockScreen(for: item) else { return false }
        return !gameState.unlockedModes.contains(requiredScreen)
    }

    private func requiredUnlockScreen(for item: HomeMenuItem) -> GameScreen? {
        switch item {
        case .training:
            return .training
        case .arcade:
            return .arcade
        case .events:
            return .events
        case .survival:
            return .survival
        case .versus:
            return .versus
        default:
            return nil
        }
    }

    private func syncFooterPageWithCurrentScreen() {
        guard let matchingIndex = pageIndex(for: gameState.screen) else { return }
        footerPageIndex = matchingIndex
    }

    private func pageIndex(for screen: GameScreen) -> Int? {
        switch screen {
        case .home, .start, .story, .shop, .backgrounds, .skin, .summon, .season, .missiona, .exchange, .gift, .daily, .cards:
            return 0
        case .arcade, .training, .events, .survival:
            return 1
        case .options:
            return 2
        default:
            return nil
        }
    }

    private func shiftFooterPage(by delta: Int) {
        let pageCount = footerPages.count
        guard pageCount > 0 else { return }
        footerPageIndex = wrappedPageIndex(from: footerPageIndex, delta: delta)
    }

    private func wrappedPageIndex(from index: Int, delta: Int) -> Int {
        let pageCount = footerPages.count
        guard pageCount > 0 else { return 0 }
        return (index + delta + pageCount) % pageCount
    }
}
