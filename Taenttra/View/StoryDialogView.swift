//
//  StoryDialogView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct StoryDialogView: View {
    let dialog: StoryDialog
    let onContinue: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            backgroundLayer
                .opacity(appear ? 1 : 0)

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 18) {
                    Text("STORY DIALOG")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(2.2)
                        .foregroundStyle(.cyan.opacity(0.85))

                    Image(dialog.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.8), radius: 24)
                        .scaleEffect(appear ? 1 : 0.95)
                        .opacity(appear ? 1 : 0)

                    VStack(spacing: 14) {
                        Text(dialog.text)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 160, height: 2)

                        Button {
                            onContinue()
                        } label: {
                            Text("CONTINUE")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .tracking(2)
                                .foregroundColor(.black)
                                .padding(.horizontal, 44)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white, .cyan, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                                )
                                .shadow(color: Color.cyan.opacity(0.4), radius: 14)
                        }
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.cyan.opacity(0.24), lineWidth: 1)
                            )
                    )
                }
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

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.01, blue: 0.14),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 36)
                .offset(x: -120, y: -210)

            Circle()
                .fill(Color.pink.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 42)
                .offset(x: 140, y: 180)

            Color.black.opacity(0.42)
                .ignoresSafeArea()
        }
    }
}
