import Foundation
import CoreGraphics

/// Mức âm lượng placeholder (3 nấc thay slider).
enum VolumeLevel: String, CaseIterable {
    case off, low, high
    var value: Float {
        switch self {
        case .off: return 0
        case .low: return 0.35
        case .high: return 0.8
        }
    }
    var label: String {
        switch self {
        case .off: return "Tắt"
        case .low: return "Nhỏ"
        case .high: return "To"
        }
    }
    var next: VolumeLevel {
        let all = VolumeLevel.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }
}

/// Kích thước cụm nút điều khiển (accessibility vận động + sở thích).
enum ControlScale: String, CaseIterable {
    case small, medium, large
    var factor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.25
        }
    }
    var label: String {
        switch self {
        case .small: return "Nhỏ"
        case .medium: return "Vừa"
        case .large: return "Lớn"
        }
    }
    var next: ControlScale {
        let all = ControlScale.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }
}

/// Nguồn duy nhất cho mọi tuỳ chọn — lưu UserDefaults, inject được để test.
final class SettingsStore {

    static let shared = SettingsStore()

    private enum Key {
        static let audioEnabled = "audio.enabled"   // giữ tương thích AudioManager cũ
        static let sfxVolume = "settings.sfxVolume"
        static let bgmVolume = "settings.bgmVolume"
        static let controlScale = "settings.controlScale"
        static let hapticEnabled = "settings.haptic"
        static let leftHanded = "settings.leftHanded"
    }

    private let store: KeyValueStore

    init(store: KeyValueStore = UserDefaults.standard) {
        self.store = store
    }

    // MARK: - Audio

    var audioEnabled: Bool {
        get { (store.object(forKey: Key.audioEnabled) as? Bool) ?? true }
        set { store.set(newValue, forKey: Key.audioEnabled) }
    }

    var sfxVolume: VolumeLevel {
        get { readEnum(Key.sfxVolume, default: .high) }
        set { store.set(newValue.rawValue, forKey: Key.sfxVolume) }
    }

    var bgmVolume: VolumeLevel {
        get { readEnum(Key.bgmVolume, default: .low) }
        set { store.set(newValue.rawValue, forKey: Key.bgmVolume) }
    }

    // MARK: - Controls

    var controlScale: ControlScale {
        get { readEnum(Key.controlScale, default: .medium) }
        set { store.set(newValue.rawValue, forKey: Key.controlScale) }
    }

    var leftHanded: Bool {
        get { (store.object(forKey: Key.leftHanded) as? Bool) ?? false }
        set { store.set(newValue, forKey: Key.leftHanded) }
    }

    // MARK: - Haptic

    var hapticEnabled: Bool {
        get { (store.object(forKey: Key.hapticEnabled) as? Bool) ?? true }
        set { store.set(newValue, forKey: Key.hapticEnabled) }
    }

    // MARK: - Helpers

    private func readEnum<T: RawRepresentable>(_ key: String, default def: T) -> T where T.RawValue == String {
        guard let raw = store.object(forKey: key) as? String, let v = T(rawValue: raw) else { return def }
        return v
    }
}
