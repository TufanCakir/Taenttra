//
//  StoryDialogView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import SwiftUI

struct StoryDialogView: View {

    let dialog: StoryDialog
    let onContinue: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {

            // 🌑 Dark cinematic background
            Color.black
                .ignoresSafeArea()
                .opacity(appear ? 1 : 0)

            VStack(spacing: 24) {

                Spacer()

                // 🖼 Character / Scene Image
                Image(dialog.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.8), radius: 24)
                    .scaleEffect(appear ? 1 : 0.95)
                    .opacity(appear ? 1 : 0)

                // 💬 Dialog Box
                VStack(spacing: 14) {

                    Text(dialog.text)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Divider()
                        .background(Color.white.opacity(0.2))

                    Button {
                        onContinue()
                    } label: {
                        Text("CONTINUE")
                            .font(.system(size: 14, weight: .heavy))
                            .tracking(2)
                            .foregroundColor(.black)
                            .padding(.horizontal, 44)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.cyan)
                                    .shadow(
                                        color: Color.cyan.opacity(0.7),
                                        radius: 14
                                    )
                            )
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.75))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .offset(y: appear ? 0 : 40)
                .opacity(appear ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                appear = true
            }
        }
        .preferredColorScheme(.dark)
    }
}
