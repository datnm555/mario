import AVFoundation

/// Hiệu ứng âm thanh — raw value = tên file .wav trong bundle.
enum SoundEffect: String, CaseIterable {
    case jump, coin, stomp, powerup, fireball, death, brick, win
}

/// Quản lý BGM + SFX. Preload player để phát không trễ.
/// Cờ bật/tắt + âm lượng đọc từ SettingsStore (nguồn duy nhất).
final class AudioManager {

    static let shared = AudioManager()

    private let settings: SettingsStore
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var bgmPlayer: AVAudioPlayer?

    init(settings: SettingsStore = .shared, preload: Bool = true) {
        self.settings = settings
        if preload {
            configureSession()
            preloadEffects()
        }
    }

    var isEnabled: Bool { settings.audioEnabled }

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
        guard isEnabled, settings.sfxVolume != .off, let player = players[effect] else { return }
        player.volume = settings.sfxVolume.value
        player.currentTime = 0
        player.play()
    }

    func startBGM() {
        guard isEnabled, settings.bgmVolume != .off else { return }
        if bgmPlayer == nil,
           let url = Bundle.main.url(forResource: "bgm", withExtension: "wav"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = -1   // lặp vô hạn
            bgmPlayer = player
        }
        bgmPlayer?.volume = settings.bgmVolume.value
        bgmPlayer?.currentTime = 0
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    // MARK: - Settings passthrough

    func setEnabled(_ on: Bool) {
        settings.audioEnabled = on
        if !on { stopBGM() }
    }

    func toggleEnabled() { setEnabled(!isEnabled) }

    /// Áp lại âm lượng ngay khi đổi trong settings.
    func refreshVolume() {
        bgmPlayer?.volume = settings.bgmVolume.value
        if !isEnabled || settings.bgmVolume == .off { stopBGM() }
    }
}
