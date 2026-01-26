//
//  ConnectionRequiredView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 26.01.26.
//

import SwiftUI

struct ConnectionRequiredView: View {

    let message: String

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.7))

                Text("Connection Required")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button("Retry") {
                    Task {
                        await GameCenterManager.shared.authenticate()
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.mint)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
        }
    }
}
