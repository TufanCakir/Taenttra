//
//  CrystalShopView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import StoreKit
import SwiftUI

struct BackgroundShopItem {
    let style: BackgroundStyle
    let price: Int
}

enum ShopCategory: String, CaseIterable, Identifiable {
    case backgrounds = "Backgrounds"
    case crystals = "Crystals"

    var id: String { rawValue }
}

let backgroundShop: [BackgroundShopItem] = [
    .init(style: .redGrid, price: 250),
    .init(style: .purpleGrid, price: 400),
    .init(style: .emeraldGrid, price: 600),
    .init(style: .raidPNG, price: 800),
    .init(style: .background8PNG, price: 1200),
]

struct CrystalShopView: View {

    @EnvironmentObject var bgManager: BackgroundManager

    @State private var selectedCategory: ShopCategory = .backgrounds
    @State private var showConfirm = false
    @State private var showNotEnough = false
    @State private var selectedItem: BackgroundShopItem?

    @StateObject private var store = CrystalStore.shared

    var body: some View {
        ZStack {
            // 🌌 Background
            SpiritGridBackground(style: bgManager.selected)
                .ignoresSafeArea()

            VStack(spacing: 12) {

                // 🔹 FIXED HEADER
                Text("Shop")
                    .font(.largeTitle.bold())
                    .padding(.top, 12)

                categoryBar

                // 🔹 SCROLLABLE CONTENT (ONLY THIS SCROLLS)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if selectedCategory == .backgrounds {
                            backgroundShopView
                        } else {
                            crystalPackView
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal)
        }
        .task {
            await store.loadProducts()
        }
        .confirmationDialog(
            "Buy Background?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            if let item = selectedItem {
                Button("Buy for \(item.price) 💎", role: .destructive) {
                    if CrystalManager.shared.spendCrystals(item.price) {
                        BackgroundManager.shared.unlock(item.style)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Not enough Crystals", isPresented: $showNotEnough) {
            Button("Get Crystals") {
                withAnimation {
                    selectedCategory = .crystals
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You don’t have enough 💎 to buy this background.")
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ShopCategory.allCases) { category in
                    Text(category.rawValue)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(
                                self.selectedCategory == category
                                    ? Color.blue.opacity(0.8)
                                    : Color.white.opacity(0.15)
                            )
                        )
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.selectedCategory = category
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var backgroundShopView: some View {
        VStack(spacing: 12) {
            ForEach(backgroundShop, id: \.style) { item in
                Button {
                    if CrystalManager.shared.crystals < item.price {
                        self.showNotEnough = true
                    } else {
                        self.selectedItem = item
                        self.showConfirm = true
                    }
                } label: {
                    HStack {
                        SpiritGridBackground(style: item.style)
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)

                        VStack(alignment: .leading) {
                            Text(item.style.rawValue)
                            if let crystalIcon = HudIconManager.shared.icon(
                                for: "crystal"
                            ) {
                                HStack(spacing: 6) {
                                    Image(systemName: crystalIcon.symbol)
                                        .foregroundColor(
                                            Color(hex: crystalIcon.color)
                                        )

                                    Text("\(item.price)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()

                        if BackgroundManager.shared.isUnlocked(item.style) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
            }
        }
    }

    private var crystalPackView: some View {
        VStack(spacing: 12) {

            Text("Restore Purchases")
                .font(.footnote)
                .foregroundColor(.secondary)
                .underline()
                .onTapGesture {
                    Task { await store.restore() }
                }

            if store.isLoading {
                ProgressView()
            }

            ForEach(store.products) { product in
                Button {
                    Task { await store.buy(product) }
                } label: {
                    HStack {
                        Text(product.displayName)
                        Spacer()
                        Text(product.displayPrice)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
            }
        }
    }
}
