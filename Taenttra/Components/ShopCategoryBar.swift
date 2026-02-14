//
//  ShopCategoryBar.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct ShopCategoryBar: View {

    let categories: [ShopCategory]
    let selected: ShopCategory?
    let onSelect: (ShopCategory) -> Void

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {

                ForEach(categories) { category in
                    Button {
                        onSelect(category)
                    } label: {

                        VStack {
                            Image(category.icon)
                                .resizable()
                                .frame(width: 40, height: 40)

                            Text(category.title)
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(
                            selected?.id == category.id
                            ? Color.blue.opacity(0.3)
                            : Color.clear
                        )
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}
