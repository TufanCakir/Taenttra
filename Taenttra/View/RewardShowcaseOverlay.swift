//
//  RewardShowcaseOverlay.swift
//  Taenttra
//
//  Created by OpenAI on 2025.
//

import SwiftUI
import UIKit

enum RewardShowcasePayload {
    case theme(BackgroundTheme)
    case skin(title: String, preview: String, rarityText: String, accent: Color)
    case card(template: BattleCardTemplate)

    var accentColor: Color {
        switch self {
        case .theme(let theme):
            return theme.rarity.chipColor
        case .skin(_, _, _, let accent):
            return accent
        case .card(let template):
            return template.rarity.showcaseColor
        }
    }

    var titleText: String {
        switch self {
        case .theme(let theme):
            return theme.name.uppercased()
        case .skin(let title, _, _, _):
            return title.uppercased()
        case .card(let template):
            return template.title.uppercased()
        }
    }

    var subtitleText: String {
        switch self {
        case .theme(let theme):
            return "\(theme.rarity.title) • \(theme.unlockSource.title)"
        case .skin(_, _, let rarityText, _):
            return rarityText
        case .card(let template):
            return "\(template.rarity.displayTitle) • \(template.role.displayTitle) • COST \(template.energyCost)"
        }
    }

    var detailText: String? {
        switch self {
        case .card(let template):
            return template.ultimateText
        default:
            return nil
        }
    }
}

struct RewardShowcaseOverlay: View {
    let heading: String
    let payload: RewardShowcasePayload
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.68)
                .ignoresSafeArea()
                .onTapGesture(perform: dismiss)

            VStack(spacing: 16) {
                Text(heading)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(payload.accentColor)

                previewCard

                VStack(spacing: 4) {
                    Text(payload.titleText)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .tracking(1.3)
                        .foregroundStyle(.white)

                    Text(payload.subtitleText)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(payload.accentColor)
                }

                if let detailText = payload.detailText {
                    Text(detailText)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                Button(action: dismiss) {
                    Text("CONTINUE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(payload.accentColor))
                }
                .buttonStyle(.plain)
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.84))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(payload.accentColor.opacity(0.26), lineWidth: 1.2)
                    )
            )
            .padding(.horizontal, 26)
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var previewCard: some View {
        switch payload {
        case .theme(let theme):
            AppBackgroundView(theme: theme, cornerRadius: 28, shadowOpacity: 0.12)
                .frame(height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(theme.rarity.chipColor.opacity(0.5), lineWidth: 1.4)
                )
        case .skin(_, let preview, _, let accent):
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.42),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.9),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .shadow(color: accent.opacity(0.22), radius: 12)
            }
            .frame(height: 220)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accent.opacity(0.5), lineWidth: 1.4)
            )
        case .card(let template):
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                template.rarity.showcaseColor.opacity(0.42),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(template.role.displayTitle)
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.3)
                            .foregroundStyle(template.rarity.showcaseColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.38), in: Capsule())

                        Spacer()

                        Text("\(template.energyCost)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(template.rarity.showcaseColor.opacity(0.95)))
                    }

                    if let artworkName = template.artworkName, UIImage(named: artworkName) != nil {
                        Image(artworkName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 108)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(template.subtitle.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.4)
                            .foregroundStyle(.white.opacity(0.68))

                        Text(template.title.uppercased())
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        HStack {
                            Text(template.rarity.displayTitle)
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(template.rarity.showcaseColor)
                            Spacer()
                            Text("\(template.power)")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(18)
            }
            .frame(height: 220)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(template.rarity.showcaseColor.opacity(0.5), lineWidth: 1.4)
            )
        }
    }
}

private extension BattleCardRarity {
    var showcaseColor: Color {
        switch self {
        case .common:
            return .white.opacity(0.72)
        case .rare:
            return .cyan
        case .epic:
            return .purple
        case .legendary:
            return .yellow
        }
    }
}
