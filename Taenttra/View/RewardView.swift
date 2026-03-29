//
//  RewardView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct RewardView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)
        }
    }
}
