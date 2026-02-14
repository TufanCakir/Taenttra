//
//  FooterView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct FooterView: View {

    @StateObject private var vm = FooterViewModel()
    @Binding var selectedTab: FooterTab?

    var body: some View {

        HStack(spacing: 16) {

            ForEach(vm.tabs) { tab in

                let selected = selectedTab == tab

                Button {
                    selectedTab = tab
                } label: {

                    VStack(spacing: 8) {

                        ZStack {

                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    selected
                                    ? Color.blue.opacity(0.5)
                                    : Color.blue.opacity(0.25)
                                )
                                .frame(width: 58, height: 58)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )

                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(tab.title)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(selected ? .white : .white.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 18) // 👈 Abstand zum Home Indicator
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.22),
                    Color(red: 0.02, green: 0.05, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}


#Preview {
    FooterView(selectedTab: .constant(nil))
}
