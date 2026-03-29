//
//  SongLibrary.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

import Foundation

final class SongLibrary {

    static let shared = SongLibrary()

    let songs: [Song]

    private init() {
        let url = Bundle.main.url(forResource: "songs", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        songs = try! JSONDecoder().decode(SongContainer.self, from: data).songs
    }

    // ✅ DAS FEHLTE
    func song(for key: String) -> Song? {
        songs.first { $0.key == key }
    }
}

struct SongContainer: Codable {
    let songs: [Song]
}
