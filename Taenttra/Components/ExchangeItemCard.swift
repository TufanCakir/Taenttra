//
//  ExchangeItemCard.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct ExchangeItemCard: View {

    let item: ExchangeItem
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

                Text("\(item.cost) \(item.currency)")
                    .foregroundColor(.yellow)

                Button("Exchange", action: action)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(height: 220)
    }
}

