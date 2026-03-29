//
//  LicensesView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import SwiftUI

struct LicensesView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 18
    }

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView {
                VStack(spacing: 20) {
                    heroCard

                    sectionCard(
                        title: "APP INFO",
                        accent: .cyan
                    ) {
                        infoRow("GAME", "TAENTTRA")
                        infoRow("COPYRIGHT", "© 2026 TUFAN CAKIR")
                        infoRow("STATUS", "ALLE RECHTE VORBEHALTEN")
                    }

                    sectionCard(
                        title: "OPEN SOURCE",
                        accent: .orange
                    ) {
                        Text("Taenttra verwendet Open-Source-Software. Die folgenden Lizenzbedingungen gelten für enthaltene Komponenten.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    sectionCard(
                        title: "THIRD-PARTY LIBRARIES",
                        accent: .pink
                    ) {
                        Text("Derzeit werden keine externen Drittanbieter-Bibliotheken verwendet.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Spacer(minLength: 28)
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("LIZENZEN")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.07),
                    Color(red: 0.04, green: 0.04, blue: 0.14),
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
                .fill(Color.orange.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 42)
                .offset(x: 140, y: 180)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.32),
                            Color.orange.opacity(0.18),
                            Color.black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    heroChip(title: "LICENSES", color: .cyan)
                    Spacer()
                    heroChip(title: "LEGAL", color: .white)
                }

                Spacer()

                Text("SYSTEM NOTICE")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white)

                Text("Overview of copyright, open-source usage, and third-party software status.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(22)
        }
        .frame(height: 192)
        .shadow(color: .cyan.opacity(0.18), radius: 20)
    }

    private func sectionCard<Content: View>(
        title: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(accent)

                Spacer()

                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)
            }

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(accent.opacity(0.24), lineWidth: 1)
                )
        )
        .shadow(color: accent.opacity(0.12), radius: 12)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.58))
                .frame(width: 88, alignment: .leading)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
    }

    private func heroChip(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }
}
