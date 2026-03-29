//
//  AudioManager.swift
//  Slayken
//
//  Created by Tufan Cakir on 28.03.26.
//

import AVFoundation
import Combine

enum MusicContext {
    case none
    case menu
    case fight
}

final class AudioManager: NSObject, ObservableObject {
    private enum Defaults {
        static let musicEnabled = "musicEnabled"
        static let volume = "musicVolume"
    }

    private enum Mode {
        case single
        case playlist
    }

    static let shared = AudioManager()

    @Published var musicEnabled: Bool = true
    @Published var volume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(volume, forKey: Defaults.volume)

            if let song = currentSong {
                player?.volume = song.volume * volume
            }
        }
    }

    private var context: MusicContext = .none
    private var mode: Mode = .playlist
    private var player: AVAudioPlayer?
    private var currentSong: Song?
    private var playlist: [Song] = []
    private var playlistIndex = 0

    private override init() {
        super.init()

        musicEnabled =
            UserDefaults.standard.object(forKey: Defaults.musicEnabled) as? Bool
            ?? true
        volume =
            UserDefaults.standard.object(forKey: Defaults.volume) as? Float
            ?? 0.7
    }

    func playMenuMusic() {
        guard musicEnabled else { return }
        guard context != .fight else { return }
        guard !(context == .menu && mode == .playlist && player?.isPlaying == true) else {
            return
        }

        context = .menu
        mode = .playlist
        playlist = SongLibrary.shared.songs
        playlistIndex = 0

        playNext()
    }

    func playFightMusic(key: String) {
        guard musicEnabled else { return }
        guard !(context == .fight && currentSong?.key == key && player?.isPlaying == true) else {
            return
        }

        context = .fight
        playSong(key: key)
    }

    func endFight() {
        resetPlayback(clearContext: true)
    }

    func playSong(key: String) {
        guard musicEnabled else { return }
        guard let song = SongLibrary.shared.song(for: key) else { return }

        context = context == .none ? .menu : context
        mode = .single
        playlist.removeAll()
        playlistIndex = 0
        play(song)
    }

    func stopMusic() {
        resetPlayback(clearContext: false)
    }

    func setEnabled(_ enabled: Bool) {
        musicEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Defaults.musicEnabled)

        guard enabled else {
            resetPlayback(clearContext: true)
            return
        }

        if context == .menu || context == .none {
            playMenuMusic()
        }
    }

    private func playNext() {
        guard musicEnabled, mode == .playlist, !playlist.isEmpty else { return }

        let song = playlist[playlistIndex]
        playlistIndex = (playlistIndex + 1) % playlist.count
        play(song)
    }

    private func play(_ song: Song) {
        if let current = currentSong,
            current.file == song.file,
            player?.isPlaying == true
        {
            return
        }

        resetPlayback(clearContext: false)

        guard
            let url = Bundle.main.url(
                forResource: song.file,
                withExtension: "mp3"
            )
        else {
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.numberOfLoops = song.loop ? -1 : 0
            audioPlayer.volume = song.volume * volume
            audioPlayer.play()

            player = audioPlayer
            currentSong = song
        } catch {
            resetPlayback(clearContext: false)
        }
    }

    private func resetPlayback(clearContext: Bool) {
        player?.stop()
        player = nil
        currentSong = nil

        if mode == .single {
            playlist.removeAll()
            playlistIndex = 0
        }

        if clearContext {
            context = .none
            mode = .single
            playlist.removeAll()
            playlistIndex = 0
        }
    }
}

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
