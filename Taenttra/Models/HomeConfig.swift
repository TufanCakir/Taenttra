//
//  HomeConfig.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation
import Combine

struct HomeConfig: Codable {
    let background: BackgroundConfig
    let buttons: [ButtonConfig]
}

struct BackgroundConfig: Codable {
    let image: String
    let zoom: CGFloat
}

struct ButtonConfig: Codable, Identifiable {
    let id: String
    let type: String
    let icon: String
    let x: CGFloat
    let y: CGFloat
    let color: String
    let size: CGFloat
}


class HomeViewModel: ObservableObject {
    @Published var config: HomeConfig?

    init() {
        loadJSON()
    }

    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "home", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(HomeConfig.self, from: data) else {
            print("JSON Fehler")
            return
        }

        config = decoded
    }
}

