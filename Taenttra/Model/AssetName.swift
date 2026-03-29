//
//  AssetName.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.03.26.
//

enum AssetName {

    static func character(
        key: String,
        skin: String,
        state: String
    ) -> String {
        "char_\(key)_\(skin)_\(state)"
    }

    static func preview(
        key: String,
        skin: String
    ) -> String {
        "char_\(key)_\(skin)_preview"
    }
}
