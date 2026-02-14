//
//  JSONLoader.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

final class JSONLoader {

    static func decode<T: Decodable>(_ type: T.Type, from fileName: String) -> T? {

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("File not found:", fileName)
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decode error:", error)
            return nil
        }
    }
}
