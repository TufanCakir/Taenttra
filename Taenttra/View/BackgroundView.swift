//
//  BackgroundView.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI

struct AppBackgroundView: View {
    let theme: BackgroundTheme
    var cornerRadius: CGFloat = 0
    var shadowOpacity: Double = 0.18

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                LinearGradient(
                    colors: [theme.topColor, theme.bottomColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if let imageAssetName = theme.imageAssetName {
                    Image(imageAssetName)
                        .resizable()
                        .scaledToFill()
                        .opacity(theme.imageOpacity)
                        .scaleEffect(1.02 + (sin(time * 0.12) * 0.012))
                        .offset(x: cos(time * 0.09) * 8, y: sin(time * 0.07) * 10)
                        .blendMode(.screen)
                }

                Circle()
                    .fill(theme.glowColor.opacity(0.26))
                    .frame(width: 360, height: 360)
                    .blur(radius: 48)
                    .offset(x: -120 + cos(time * 0.22) * 14, y: -220 + sin(time * 0.18) * 16)

                Circle()
                    .fill(theme.secondaryGlowColor.opacity(0.24))
                    .frame(width: 420, height: 420)
                    .blur(radius: 54)
                    .offset(x: 180 + sin(time * 0.16) * 18, y: 180 + cos(time * 0.12) * 14)

                effectOverlay(time: time)
                premiumOverlay(time: time)

                LinearGradient(
                    colors: [
                        .white.opacity(0.08),
                        .clear,
                        theme.accentColor.opacity(0.14),
                        .clear,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(sin(time * 0.08) * 3))
                .blendMode(.screen)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: theme.accentColor.opacity(shadowOpacity), radius: 18)
        }
    }

    @ViewBuilder
    private func premiumOverlay(time: TimeInterval) -> some View {
        switch theme.premiumEffect {
        case .starfield:
            starfieldOverlay(time: time)
        case .sparks:
            sparksOverlay(time: time)
        case .lightning:
            lightningOverlay(time: time)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func effectOverlay(time: TimeInterval) -> some View {
        switch theme.effectStyle {
        case .grid:
            gridOverlay(time: time)
        case .rings:
            ringsOverlay(time: time)
        case .beams:
            beamsOverlay(time: time)
        case .shards:
            shardsOverlay(time: time)
        case .halo:
            haloOverlay(time: time)
        }
    }

    private func gridOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<max(theme.detailCount, 4), id: \.self) { index in
                    Rectangle()
                        .fill(theme.accentColor.opacity(theme.meshOpacity))
                        .frame(width: proxy.size.width * 1.6, height: 1)
                        .rotationEffect(.degrees(Double(index * 14) - 28 + sin(time * 0.12 + Double(index)) * 4))
                        .offset(
                            x: cos(time * 0.2 + Double(index)) * 12,
                            y: CGFloat(index * 28) - proxy.size.height * 0.22 + sin(time * 0.24 + Double(index)) * 8
                        )
                }
            }
        }
    }

    private func ringsOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<max(theme.detailCount, 4), id: \.self) { index in
                    Circle()
                        .stroke(
                            index.isMultiple(of: 2)
                                ? theme.accentColor.opacity(0.16)
                                : theme.secondaryGlowColor.opacity(0.14),
                            lineWidth: CGFloat(index.isMultiple(of: 2) ? 2 : 1)
                        )
                        .frame(
                            width: proxy.size.width * (0.32 + CGFloat(index) * 0.12),
                            height: proxy.size.width * (0.32 + CGFloat(index) * 0.12)
                        )
                        .rotationEffect(.degrees(time * (2.8 + Double(index) * 0.8)))
                        .offset(
                            x: CGFloat(index * 14) - 42 + cos(time * 0.22 + Double(index)) * 10,
                            y: CGFloat(index * 8) - 34 + sin(time * 0.2 + Double(index)) * 12
                        )
                        .blur(radius: index == 0 ? 0 : 0.4)
                }
            }
        }
    }

    private func beamsOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<max(theme.detailCount, 5), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 999)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.accentColor.opacity(0.22),
                                    theme.secondaryGlowColor.opacity(0.04),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: proxy.size.width * 1.35,
                            height: CGFloat(index.isMultiple(of: 2) ? 18 : 10)
                        )
                        .rotationEffect(.degrees(Double(index * 11) - 36 + sin(time * 0.4 + Double(index)) * 6))
                        .offset(
                            x: sin(time * 0.34 + Double(index)) * 34,
                            y: CGFloat(index * 34) - proxy.size.height * 0.28 + cos(time * 0.28 + Double(index)) * 14
                        )
                        .blur(radius: 6)
                }
            }
        }
    }

    private func shardsOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<max(theme.detailCount, 6), id: \.self) { index in
                    UnevenRoundedRectangle(
                        topLeadingRadius: 6,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 6,
                        topTrailingRadius: 20
                    )
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.accentColor.opacity(0.22),
                                theme.glowColor.opacity(0.06),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 34, height: CGFloat(120 + (index * 14)))
                    .rotationEffect(.degrees(Double(index * 17) - 28 + sin(time * 0.36 + Double(index)) * 10))
                    .offset(
                        x: CGFloat(index * 36) - proxy.size.width * 0.32 + cos(time * 0.26 + Double(index)) * 16,
                        y: CGFloat(index * 8) - proxy.size.height * 0.18 + sin(time * 0.3 + Double(index)) * 18
                    )
                    .blur(radius: index.isMultiple(of: 3) ? 1 : 0)
                }
            }
        }
    }

    private func haloOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.12 + ((sin(time * 0.5) + 1) * 0.03)))
                    .frame(width: proxy.size.width * 0.62, height: proxy.size.width * 0.62)
                    .blur(radius: 28)
                    .scaleEffect(1 + sin(time * 0.42) * 0.04)

                ForEach(0..<max(theme.detailCount, 4), id: \.self) { index in
                    Circle()
                        .stroke(
                            theme.secondaryGlowColor.opacity(0.14 - Double(index) * 0.02),
                            lineWidth: CGFloat(index == 0 ? 4 : 2)
                        )
                        .frame(
                            width: proxy.size.width * (0.28 + CGFloat(index) * 0.12),
                            height: proxy.size.width * (0.28 + CGFloat(index) * 0.12)
                        )
                        .rotationEffect(.degrees(time * (4 + Double(index))))
                        .scaleEffect(1 + sin(time * 0.3 + Double(index)) * 0.03)
                }

                Capsule()
                    .fill(theme.glowColor.opacity(0.18))
                    .frame(width: proxy.size.width * 0.74, height: 12)
                    .blur(radius: 10)
                    .offset(y: proxy.size.height * 0.18 + sin(time * 0.46) * 8)
            }
        }
    }

    private func starfieldOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    Circle()
                        .fill(
                            index.isMultiple(of: 3)
                                ? theme.accentColor.opacity(0.8)
                                : Color.white.opacity(0.7)
                        )
                        .frame(width: CGFloat((index % 3) + 2), height: CGFloat((index % 3) + 2))
                        .blur(radius: index.isMultiple(of: 4) ? 1.5 : 0)
                        .offset(
                            x: CGFloat((index * 37) % 240) - proxy.size.width * 0.42 + cos(time * 0.18 + Double(index)) * 10,
                            y: CGFloat((index * 53) % 420) - proxy.size.height * 0.46 + sin(time * 0.16 + Double(index)) * 14
                        )
                        .opacity(0.4 + ((sin(time * 0.8 + Double(index)) + 1) * 0.28))
                }
            }
        }
    }

    private func sparksOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<12, id: \.self) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.glowColor.opacity(0.95),
                                    theme.accentColor.opacity(0.12),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3, height: CGFloat(34 + (index % 4) * 12))
                        .blur(radius: 0.6)
                        .rotationEffect(.degrees(Double(index * 7) - 16))
                        .offset(
                            x: CGFloat((index * 32) % 220) - proxy.size.width * 0.35 + sin(time * 0.7 + Double(index)) * 18,
                            y: CGFloat((index * 44) % 260) - proxy.size.height * 0.08 - CGFloat((sin(time * 1.2 + Double(index)) + 1) * 70)
                        )
                        .opacity(0.22 + ((sin(time * 1.4 + Double(index)) + 1) * 0.22))
                }
            }
        }
    }

    private func lightningOverlay(time: TimeInterval) -> some View {
        GeometryReader { proxy in
            let flash = max(0, sin(time * 2.6))

            ZStack {
                Path { path in
                    let startX = proxy.size.width * 0.24 + CGFloat(sin(time * 0.9) * 18)
                    let startY = proxy.size.height * 0.08
                    path.move(to: CGPoint(x: startX, y: startY))

                    for index in 1...6 {
                        let progress = CGFloat(index) / 6
                        let x = startX + CGFloat(index.isMultiple(of: 2) ? 22 : -18) + CGFloat(cos(time + Double(index)) * 8)
                        let y = startY + proxy.size.height * progress * 0.78
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(
                    theme.accentColor.opacity(0.08 + flash * 0.42),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: 1.2)

                Rectangle()
                    .fill(Color.white.opacity(flash * 0.08))
                    .blendMode(.screen)
            }
        }
    }
}

struct BackgroundView: View {
    @EnvironmentObject private var gameState: GameState

    @State private var feedbackMessage: String?

    private let catalog = BackgroundThemeLoader.load()

    private var wallet: PlayerWallet? {
        gameState.wallet
    }

    private var selectedTheme: BackgroundTheme {
        BackgroundThemeService.theme(for: wallet?.selectedBackgroundThemeID)
    }

    private var ownedCount: Int {
        guard let wallet else { return 0 }
        return catalog.themes.filter { BackgroundThemeService.isOwned(themeID: $0.id, wallet: wallet) }.count
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppBackgroundView(theme: selectedTheme)
                .ignoresSafeArea()

            Color.black.opacity(0.28)
                .ignoresSafeArea()

            GameBackButton {
                gameState.goBack()
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .zIndex(10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VersusHeaderView()
                    heroCard
                    themeGrid
                }
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 28)
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                tag("THEME LAB", color: selectedTheme.accentColor)
                if selectedTheme.rarity == .legendary {
                    tag("LEGENDARY SIGNAL", color: selectedTheme.rarity.chipColor)
                }
                Spacer()
                tag("\(ownedCount)/\(catalog.themes.count) OWNED", color: .white)
            }

            Text("GLOBAL BACKGROUNDS")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text(feedbackMessage ?? "Choose a global arena theme. Shop purchases unlock PNG scenes and custom FX themes for the whole app.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            HStack(spacing: 10) {
                infoChip(title: "EQUIPPED", value: selectedTheme.name.uppercased(), accent: selectedTheme.accentColor)
                infoChip(title: "STYLE", value: selectedTheme.kind == .asset ? "PNG" : "FX", accent: .yellow)
                infoChip(title: "RARITY", value: selectedTheme.rarity.title, accent: selectedTheme.rarity.chipColor)
                infoChip(title: "SOURCE", value: selectedTheme.unlockSource.title, accent: selectedTheme.unlockSource.accentColor)
            }

            if selectedTheme.rarity == .legendary {
                legendarySpotlight(theme: selectedTheme)
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.black.opacity(0.38))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(selectedTheme.rarity.chipColor.opacity(0.24), lineWidth: selectedTheme.rarity == .legendary ? 1.4 : 1)
                )
        )
        .shadow(
            color: selectedTheme.rarity == .legendary
                ? selectedTheme.rarity.chipColor.opacity(0.22)
                : .clear,
            radius: 18,
            y: 8
        )
    }

    private var themeGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("AVAILABLE THEMES")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(selectedTheme.accentColor)

            LazyVStack(spacing: 14) {
                ForEach(catalog.themes) { theme in
                    themeCard(theme)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func themeCard(_ theme: BackgroundTheme) -> some View {
        let isOwned = wallet.map { BackgroundThemeService.isOwned(themeID: theme.id, wallet: $0) } ?? false
        let isEquipped = wallet.map { BackgroundThemeService.isEquipped(themeID: theme.id, wallet: $0) } ?? false

        return VStack(spacing: 12) {
            AppBackgroundView(theme: theme, cornerRadius: 22, shadowOpacity: 0.08)
                .frame(height: 140)
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 6) {
                        tag(theme.kind == .asset ? "PNG" : "FX", color: theme.accentColor)
                        tag(theme.rarity.title, color: theme.rarity.chipColor)
                        tag(theme.unlockSource.title, color: theme.unlockSource.accentColor)
                    }
                    .padding(10)
                }
                .overlay(alignment: .bottomTrailing) {
                    if isEquipped {
                        tag("LIVE", color: .green)
                            .padding(10)
                    } else if theme.rarity == .legendary {
                        tag("LEGENDARY", color: theme.rarity.chipColor)
                            .padding(10)
                    }
                }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name.uppercased())
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.white)

                    Text(theme.subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))

                    Text("\(theme.rarity.title) • \(theme.unlockSource.title)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(theme.rarity.chipColor)
                }

                Spacer()

                Button {
                    handleThemeAction(theme, isOwned: isOwned)
                } label: {
                    Text(buttonTitle(for: theme, isOwned: isOwned, isEquipped: isEquipped))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(buttonColor(isOwned: isOwned, isEquipped: isEquipped, accent: theme.accentColor))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.38))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(theme.rarity.chipColor.opacity(theme.rarity == .legendary ? 0.5 : 0.28), lineWidth: theme.rarity == .legendary ? 1.4 : 1)
                )
        )
        .shadow(
            color: theme.rarity == .legendary
                ? theme.rarity.chipColor.opacity(0.18)
                : .clear,
            radius: 14,
            y: 6
        )
    }

    private func handleThemeAction(_ theme: BackgroundTheme, isOwned: Bool) {
        guard let wallet else { return }

        if isOwned {
            BackgroundThemeService.equip(themeID: theme.id, wallet: wallet)
            feedbackMessage = "\(theme.name) equipped globally."
        } else {
            gameState.screen = theme.unlockSource.targetScreen
        }
    }

    private func buttonTitle(for theme: BackgroundTheme, isOwned: Bool, isEquipped: Bool) -> String {
        if isEquipped {
            return "EQUIPPED"
        }

        if isOwned {
            return "EQUIP"
        }

        return theme.unlockSource.title
    }

    private func buttonColor(isOwned: Bool, isEquipped: Bool, accent: Color) -> Color {
        if isEquipped {
            return .green
        }

        if isOwned {
            return accent
        }

        return .white.opacity(0.78)
    }

    private func infoChip(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.56))

            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(0.9)
                .foregroundStyle(accent)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.36))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accent.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func legendarySpotlight(theme: BackgroundTheme) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(theme.rarity.chipColor.opacity(0.18))
                    .frame(width: 46, height: 46)
                    .blur(radius: 2)

                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(theme.rarity.chipColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("LEGENDARY THEME")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(theme.rarity.chipColor)

                Text("Exclusive unlock with premium FX layer and stronger arena presentation.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.rarity.chipColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.rarity.chipColor.opacity(0.28), lineWidth: 1)
                )
        )
    }

    private func tag(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.1)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }
}
