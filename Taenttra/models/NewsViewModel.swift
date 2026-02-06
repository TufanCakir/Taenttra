//
//  NewsViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 06.02.26.
//

import Combine
import SwiftUI

final class NewsViewModel: ObservableObject {

    @Published var items: [NewsItem] = []

    init() {
        load()
    }

    func load() {
        items = NewsLoader.load()
    }

    func items(for category: NewsCategory?) -> [NewsItem] {
        guard let category else { return items }
        return items.filter { $0.category == category }
    }
}
