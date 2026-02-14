//
//  FooterViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation
import Combine

class FooterViewModel: ObservableObject {

    @Published var tabs: [FooterTab] = []

    init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "footer", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(FooterData.self, from: data)
        else {
            print("Footer JSON Fehler")
            return
        }

        tabs = decoded.tabs
        print("✅ Footer geladen")
    }
}
