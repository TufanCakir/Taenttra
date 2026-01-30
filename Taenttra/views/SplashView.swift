//
//  SplashView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 30.01.26.
//

import SwiftUI

struct SplashView: View {

    @State private var scale = 0.8
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("taenttra_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .scaleEffect(scale)
                .opacity(opacity)
                .shadow(color: .cyan.opacity(0.8), radius: 30)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

