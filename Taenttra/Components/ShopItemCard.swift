//
//  ShopItemCard.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct ShopItemCard: View {

    let item: ShopItemModel
    let action: () -> Void

    var body: some View {

        ZStack {

            Image("frame_small")
                .resizable()
                .scaledToFit()

            VStack(spacing: 10) {

                Image(item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)

                Text(item.title)
                    .bold()
                    .foregroundColor(.white)

                Text(item.price)
                    .foregroundColor(.yellow)

                Button("Buy", action: action)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(height: 220)
    }
}

