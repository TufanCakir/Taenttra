//
//  Header.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct HeaderView: View {

    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var crystalManager: CrystalManager
    @EnvironmentObject var accountManager: AccountLevelManager
    @EnvironmentObject var artefacts: ArtefactInventoryManager

    @State private var glow = false
    @State private var showDetails = false

    var body: some View {
        HStack(spacing: 18) {

            hudItem(
                key: "level",
                title: "Lv.",
                value: accountManager.level
            )

            hudItem(
                key: "coin",
                value: coinManager.coins
            )

            hudItem(
                key: "crystal",
                value: crystalManager.crystals
            )
        }
        .onTapGesture {
            showDetails = true
        }
        .sheet(isPresented: $showDetails) {
            HeaderDetailSheet()
                .environmentObject(coinManager)
                .environmentObject(crystalManager)
                .environmentObject(accountManager)
                .environmentObject(artefacts)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .white.opacity(0.15), radius: 10, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 10)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)
            ) {
                glow.toggle()
            }
        }
    }

    private func hudItem(
        key: String,
        title: String? = nil,
        value: Int
    ) -> some View {

        let icon = HudIconManager.shared.icon(for: key)
        let color = Color(hex: icon?.color ?? "#FFFFFF")

        return HStack(spacing: 6) {

            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 30, height: 30)
                    .shadow(
                        color: color.opacity(glow ? 0.5 : 0.2),
                        radius: glow ? 8 : 2
                    )

                Image(systemName: icon?.symbol ?? "questionmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 0) {
                if let title {
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }

                Text(value.short)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .frame(width: 78)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

extension Int {
    var short: String {
        let num = Double(self)
        let thousand = num / 1_000
        let million = num / 1_000_000
        let billion = num / 1_000_000_000

        if billion >= 1 {
            return String(format: "%.1fB", billion)
        } else if million >= 1 {
            return String(format: "%.1fM", million)
        } else if thousand >= 1 {
            return String(format: "%.1fK", thousand)
        } else {
            return "\(self)"
        }
    }
}

#Preview {
    HeaderView().environmentObject(CoinManager.shared).environmentObject(
        CrystalManager.shared
    ).environmentObject(AccountLevelManager.shared)
        .environmentObject(ArtefactInventoryManager.shared)
        .preferredColorScheme(.dark)
}
