//
//  VersusHeaderView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct VersusHeaderView: View {
    private enum Layout {
        static let iconSize: CGFloat = 22
        static let outerCornerRadius: CGFloat = 26
        static let innerCornerRadius: CGFloat = 14
    }

    @EnvironmentObject private var globalChrome: GlobalChromeState
    @EnvironmentObject var gameState: GameState
    private let forceVisible: Bool

    init(forceVisible: Bool = false) {
        self.forceVisible = forceVisible
    }

    private var coins: Int {
        gameState.wallet?.coins ?? 0
    }

    private var crystals: Int {
        gameState.wallet?.crystals ?? 0
    }

    private var shards: Int {
        gameState.wallet?.shards ?? 0
    }

    var body: some View {
        Group {
            if globalChrome.isEnabled && !forceVisible {
                EmptyView()
            } else {
                HStack(spacing: 12) {
                    profileBadge

                    Spacer(minLength: 10)

                    HStack(spacing: 10) {
                        currencyView(
                            title: "COIN",
                            icon: "icon_coin",
                            value: coins,
                            accent: Color(red: 1.0, green: 0.83, blue: 0.24)
                        )

                        currencyView(
                            title: "GEM",
                            icon: "icon_crystal",
                            value: crystals,
                            accent: Color.cyan
                        )

                        currencyView(
                            title: "SHARD",
                            icon: "icon_shard",
                            value: shards,
                            accent: Color.orange
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
    }

    private var profileBadge: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.95),
                                Color.blue.opacity(0.8),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black.opacity(0.82))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("TAENTTRA")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white)

                Text("BATTLE HUB")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Layout.outerCornerRadius)
                .fill(Color.black.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.outerCornerRadius)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func currencyView(
        title: String,
        icon: String,
        value: Int,
        accent: Color
    ) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .shadow(color: accent.opacity(0.35), radius: 4)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(accent.opacity(0.9))

                Text("\(value)")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: Layout.innerCornerRadius)
                .fill(Color.black.opacity(0.58))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.innerCornerRadius)
                        .stroke(accent.opacity(0.45), lineWidth: 1)
                )
        )
        .shadow(color: accent.opacity(0.16), radius: 8, y: 2)
    }
}
