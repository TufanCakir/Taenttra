//
//  ConnectionRequiredView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct ConnectionRequiredView: View {

    let message: String
    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {

                // 📡 ICON
                Image(systemName: "wifi.exclamationmark")
                    .foregroundColor(.white)

                // 🧾 TITLE
                Text("Connection Required")
                    .foregroundColor(.white)

                // 💬 MESSAGE
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // 🔁 RETRY BUTTON
                Button {
                    retryConnection()
                } label: {
                    Text("RETRY")
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.black, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
            }
            .padding()
        }
        .onAppear {
            pulse = true
        }
    }
}


private func retryConnection() {
    print("🔁 Retry tapped")

    // 🔧 hier kannst du später machen:
    // - Internet check
    // - Server reconnect
    // - Game reload
}
