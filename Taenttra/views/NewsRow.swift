//
//  NewsRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 06.02.26.
//

import SwiftUI

struct NewsRow: View {

    let item: NewsItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            if let image = item.image {
                Image(image)
                    .resizable()
                    .if(item.imageType == .background) {
                        $0.scaledToFill()
                    }
                    .if(item.imageType == .character) {
                        $0.scaledToFit()
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()

            }

            LinearGradient(
                colors: [.black.opacity(0.2), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(item.category.title)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.cyan)

                Text(item.title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(14)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.6), radius: 12, y: 6)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
