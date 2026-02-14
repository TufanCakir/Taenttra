//
//  SummonBannerCard.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct SummonBannerCard: View {

    let banner: SummonBanner

    var body: some View {

        ZStack {

            Image("raid_bg")
                .resizable()
                .scaledToFit()

            VStack(spacing: 12) {

                Image(banner.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)

                Text(banner.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text(banner.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .frame(maxWidth: 350)
    }
}
