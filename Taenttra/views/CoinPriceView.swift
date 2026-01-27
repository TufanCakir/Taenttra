//
//  CoinPriceView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct CoinPriceView: View {

    let value: Int

    var body: some View {
        HStack(spacing: 8) {
            Image("icon_coin")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)

            Text("\(value)")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
    }
}
