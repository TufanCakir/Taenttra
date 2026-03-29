//
//  BattleCardView.swift
//  Taenttra
//
//  Created by Codex on 12.08.25.
//

import SwiftUI

struct BattleCardView: View {

    private enum Layout {
        static let width: CGFloat = 122
        static let height: CGFloat = 204
        static let heroHeight: CGFloat = 102
        static let selectedLift: CGFloat = -10
        static let highlightedScale: CGFloat = 1.04
        static let normalScale: CGFloat = 0.96
    }

    let card: BattleCard
    let isSelected: Bool
    let isHighlighted: Bool
    let isDisabled: Bool
    let action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            cardBody
        }
        .buttonStyle(.plain)
        .disabled(action == nil || isDisabled)
        .scaleEffect(isHighlighted ? Layout.highlightedScale : Layout.normalScale)
        .offset(y: isSelected ? Layout.selectedLift : 0)
        .opacity(isDisabled ? 0.72 : 1)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }

    private var cardBody: some View {
        VStack(spacing: 0) {
            cardHeader
            artworkPanel
            cardFooter
        }
        .frame(width: Layout.width, height: Layout.height)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            card.frameColor.opacity(0.16),
                            Color.black.opacity(0.84)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(alignment: .top) {
            rarityFrame
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            card.frameColor.opacity(0.95),
                            card.accentColor.opacity(0.7),
                            Color.white.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHighlighted ? 3 : 2
                )
        )
        .shadow(color: card.frameColor.opacity(0.45), radius: isHighlighted ? 18 : 10, y: 8)
    }

    private var cardHeader: some View {
        HStack(alignment: .top) {
            Text("\(card.slot + 1)")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(card.frameColor)
                )

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(card.energyCost)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(card.accentColor.opacity(0.9))
                    )

                Text(card.role.displayTitle)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(card.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.66), in: Capsule())
            }
        }
        .padding(10)
    }

    private var artworkPanel: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            card.accentColor.opacity(0.18),
                            card.frameColor.opacity(0.45),
                            Color.black.opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(card.artworkName)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 8)
                .padding(.top, 4)
                .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(card.title.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .tracking(0.9)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(card.subtitle.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.7))

                Text(card.rarity.displayTitle)
                    .font(.system(size: 8, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(rarityColor)
            }
            .padding(10)
        }
        .frame(height: Layout.heroHeight)
        .padding(.horizontal, 10)
    }

    private var cardFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(card.power)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(card.isEnemy ? "ENEMY UNIT" : "BATTLE CARD")
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.66))
                }

                Spacer()

                Image(systemName: card.role == .booster ? "sparkles" : card.role == .guardUnit ? "shield.fill" : "burst.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(card.accentColor)
                    .padding(10)
                    .background(Color.white.opacity(0.08), in: Circle())
            }

            Text(card.skillText.uppercased())
                .font(.system(size: 7, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var rarityFrame: some View {
        switch card.rarity {
        case .common:
            EmptyView()
        case .rare:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.cyan.opacity(0.28), lineWidth: 1)
                .padding(4)
        case .epic:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.9), .pink.opacity(0.55), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .padding(3)
        case .legendary:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.yellow, .orange, .white.opacity(0.45), .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .padding(2)
                .shadow(color: .yellow.opacity(0.22), radius: 8)
        }
    }

    private var rarityColor: Color {
        switch card.rarity {
        case .common:
            return .white.opacity(0.7)
        case .rare:
            return .cyan
        case .epic:
            return .purple
        case .legendary:
            return .yellow
        }
    }
}
