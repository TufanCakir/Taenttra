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
    case menu
    case fight
}

final class AudioManager: NSObject, ObservableObject {

    static let shared = AudioManager()
    private var context: MusicContext = .menu

    // MARK: - Public Settings
    @Published var musicEnabled: Bool = true
    @Published var volume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(volume, forKey: AudioDefaults.volume)
            guard let song = currentSong else { return }
            player?.volume = song.volume * volume
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

        // 🔹 gespeicherte Werte laden
        let savedEnabled =
            UserDefaults.standard.object(
                forKey: AudioDefaults.musicEnabled
            ) as? Bool ?? true

        let savedVolume =
            UserDefaults.standard.object(
                forKey: AudioDefaults.volume
            ) as? Float ?? 0.7

        musicEnabled = savedEnabled
        volume = savedVolume
    }

    func playMenuMusic() {
        context = .menu
        playAll()  // oder playSong(key: "intro")
    }

    func playFightMusic(key: String) {
        context = .fight
        playSong(key: key)
    }

    private func stopMusicInternal() {
        player?.stop()
        player = nil
        currentSong = nil
    }

    func endFight() {
        if context == .fight {
            playMenuMusic()
        }
    }

    // MARK: - Single Song

    func playSong(key: String) {
        guard musicEnabled else { return }

        guard let song = SongLibrary.shared.song(for: key) else {
            print("❌ Song not found:", key)
            return
        }

        mode = .single
        playlist = []
        playlistIndex = 0
        play(song)
    }

    // MARK: - Playlist (ALL songs)

    func playAll() {
        guard musicEnabled else { return }

        playlist = SongLibrary.shared.songs
        playlistIndex = 0
        mode = .playlist
        playNext()
    }

    // MARK: - Core Playback

    private func playNext() {
        guard musicEnabled, mode == .playlist, !playlist.isEmpty else { return }

        let song = playlist[playlistIndex]
        playlistIndex = (playlistIndex + 1) % playlist.count
        play(song)
    }

    private func play(_ song: Song) {
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

        if enabled {
            switch mode {
            case .single:
                if let song = currentSong {
                    play(song)
                }
            case .playlist:
                playNext()
            }
        } else {
            stopMusic()
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
