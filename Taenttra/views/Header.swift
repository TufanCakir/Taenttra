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
    private let headerBlue = Color(hex: "#0A2A4A")  // dunkles HUD-Blau

    var body: some View {

        let icon = HudIconManager.shared.icon(for: "level")

        let color = Color(hex: icon?.color ?? "#00FF00  ")

        VStack(spacing: 16) {
            // Top row: Level left, resources right
            HStack(alignment: .top, spacing: 16) {
                // Level label on the left
                HStack {
                    Text("Rank \(accountManager.level)")
                        .font(.callout.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                // Resources on the right
                HStack(spacing: 16) {
                    hudItem(key: "coin", value: coinManager.coins)
                    hudItem(key: "crystal", value: crystalManager.crystals)
                }
            }

            // EXP bar below with spacing
            expBar
                .padding(.bottom)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .onTapGesture { showDetails = true }
        .sheet(isPresented: $showDetails) {
            HeaderDetailSheet()
                .environmentObject(coinManager)
                .environmentObject(crystalManager)
                .environmentObject(accountManager)
                .environmentObject(artefacts)
        }
        .padding(.horizontal, 16)
        .padding(.top, 0)
        .background(
            Capsule()
                .fill(headerBlue)
                .overlay(
                    Capsule()
                        .stroke(Color.blue, lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)
            ) {
                glow.toggle()
            }
        }
    }

    private var expBar: some View {
        let icon = HudIconManager.shared.icon(for: "level")
        let color = Color(hex: icon?.color ?? "#32CD32")

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.30))
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * accountManager.expProgress)
            }
        }
        .frame(height: 6)
    }

    private func hudItem(
        key: String,
        value: Int
    ) -> some View {

        let icon = HudIconManager.shared.icon(for: key)
        let color = Color(hex: icon?.color ?? "#FFFFFF")

        return HStack(spacing: 16) {
            Image(systemName: icon?.symbol ?? "questionmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            Text(value.short)
                .font(.subheadline.bold())
                .monospacedDigit()
                .foregroundColor(.white)
        }
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
