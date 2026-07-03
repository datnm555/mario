import AVFoundation

/// Hiệu ứng âm thanh — raw value = tên file .wav trong bundle.
enum SoundEffect: String, CaseIterable {
    case jump, coin, stomp, powerup, fireball, death, brick, win
}

/// Quản lý BGM + SFX. Preload player để phát không trễ. Tôn trọng cờ bật/tắt (lưu UserDefaults).
final class AudioManager {

    static let shared = AudioManager()

    private static let enabledKey = "audio.enabled"
    private let store: KeyValueStore
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var bgmPlayer: AVAudioPlayer?

    private(set) var isEnabled: Bool

    init(store: KeyValueStore = UserDefaults.standard, preload: Bool = true) {
        self.store = store
        self.isEnabled = (store.object(forKey: AudioManager.enabledKey) as? Bool) ?? true
        if preload {
            configureSession()
            preloadEffects()
        }
    }

    private func configureSession() {
        // .ambient: game audio, tôn trọng nút gạt im lặng, không ngắt nhạc app khác.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// Tên file → filename cho SoundEffect. Tách ra để test được mapping.
    func fileName(for effect: SoundEffect) -> String { "\(effect.rawValue).wav" }

    private func preloadEffects() {
        for effect in SoundEffect.allCases {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.prepareToPlay()
            players[effect] = player
        }
    }

    // MARK: - Playback

    func play(_ effect: SoundEffect) {
        guard isEnabled, let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }

    func startBGM() {
        guard isEnabled else { return }
        if bgmPlayer == nil,
           let url = Bundle.main.url(forResource: "bgm", withExtension: "wav"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = -1   // lặp vô hạn
            player.volume = 0.5
            bgmPlayer = player
        }
        bgmPlayer?.currentTime = 0
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    // MARK: - Settings

    func setEnabled(_ on: Bool) {
        isEnabled = on
        store.set(on, forKey: AudioManager.enabledKey)
        if !on { stopBGM() }
    }

    func toggleEnabled() { setEnabled(!isEnabled) }
}
