//
//  MusicVolumeSlider.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct MusicVolumeSlider: View {
    @EnvironmentObject var musicManager: MusicManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "speaker.fill")
                Text("Music Volume")
                Spacer()
                Text("\(Int(musicManager.volume * 100))%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .foregroundColor(.white)

            Slider(
                value: Binding(
                    get: { Double(musicManager.volume) },
                    set: { musicManager.volume = Float($0) }
                ),
                in: 0...1
            )
            .tint(.blue)
        }
    }
}
