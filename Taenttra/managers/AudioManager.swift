//
//  AudioManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 27.01.26.
//

import AVFoundation
import Combine
import SwiftUI

enum MusicContext {
    case none
    case menu
    case fight
}

final class AudioManager: NSObject, ObservableObject {

    static let shared = AudioManager()
    private var context: MusicContext = .none

    // MARK: - Public Settings
    @Published var musicEnabled: Bool = true
    @Published var volume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(volume, forKey: AudioDefaults.volume)
            if let song = currentSong {
                player?.volume = song.volume * volume
            }
        }
    }

    // MARK: - State
    private var player: AVAudioPlayer?
    private var currentSong: Song?
    private var playlist: [Song] = []
    private var playlistIndex: Int = 0

    private enum AudioDefaults {
        static let musicEnabled = "musicEnabled"
        static let volume = "musicVolume"
    }

    private enum Mode {
        case single
        case playlist
    }

    private var mode: Mode = .playlist

    private override init() {
        super.init()

        musicEnabled =
            UserDefaults.standard.object(forKey: AudioDefaults.musicEnabled)
            as? Bool ?? true

        volume =
            UserDefaults.standard.object(forKey: AudioDefaults.volume)
            as? Float ?? 0.7
    }

    // MARK: - Menu Music (Playlist)

    func playMenuMusic() {
        guard musicEnabled else {
            print("🔇 Music disabled – menu music blocked")
            return
        }

        guard context != .fight else { return }

        context = .menu
        mode = .playlist
        playlist = SongLibrary.shared.songs
        playlistIndex = 0

        playNext()
    }

    // MARK: - Fight Music (Single)

    func playFightMusic(key: String) {
        guard musicEnabled else {
            print("🔇 Music disabled – fight music blocked")
            return
        }

        if context == .fight, currentSong?.key == key {
            return
        }

        context = .fight
        playSong(key: key)
    }

    func endFight() {
        print("🎵 Audio Context:", context)
        stopMusic()
        context = .none
    }

    // MARK: - Core Playback

    func playSong(key: String) {
        guard musicEnabled else {
            print("🔇 Music disabled – playSong blocked:", key)
            return
        }

        guard let song = SongLibrary.shared.song(for: key) else {
            print("❌ Song not found:", key)
            return
        }

        mode = .single
        playlist.removeAll()
        play(song)
    }

    private func playNext() {
        guard
            musicEnabled,
            mode == .playlist,
            !playlist.isEmpty
        else { return }

        let song = playlist[playlistIndex]
        playlistIndex = (playlistIndex + 1) % playlist.count
        play(song)
    }

    private func play(_ song: Song) {

        // ✅ gleicher Song läuft → nichts tun
        if let current = currentSong,
            current.file == song.file,
            player?.isPlaying == true
        {
            return
        }

        stopMusic()

        guard
            let url = Bundle.main.url(
                forResource: song.file,
                withExtension: "mp3"
            )
        else {
            print("❌ Missing file:", song.file)
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.numberOfLoops = song.loop ? -1 : 0
            player?.volume = song.volume * volume
            player?.play()
            currentSong = song
        } catch {
            print("❌ Audio error:", error)
        }
    }

    // MARK: - Control

    func stopMusic() {
        player?.stop()
        player = nil
        currentSong = nil
    }

    func setEnabled(_ enabled: Bool) {
        musicEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: AudioDefaults.musicEnabled)

        if !enabled {
            stopMusic()
            context = .none  // 🔥 extrem wichtig
            mode = .single
            playlist.removeAll()
        } else {
            if context == .menu {
                playMenuMusic()
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        if mode == .playlist {
            playNext()
        }
    }
}
