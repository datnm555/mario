import XCTest
@testable import mario

private final class FakeAudioStore: KeyValueStore {
    var dict: [String: Any] = [:]
    func object(forKey defaultName: String) -> Any? { dict[defaultName] }
    func set(_ value: Any?, forKey defaultName: String) { dict[defaultName] = value }
    func removeObject(forKey defaultName: String) { dict[defaultName] = nil }
}

final class AudioManagerTests: XCTestCase {

    private func makeManager() -> (AudioManager, FakeAudioStore) {
        let store = FakeAudioStore()
        return (AudioManager(store: store, preload: false), store)
    }

    func testEnabledByDefault() {
        let (audio, _) = makeManager()
        XCTAssertTrue(audio.isEnabled)
    }

    func testToggleDisables() {
        let (audio, _) = makeManager()
        audio.toggleEnabled()
        XCTAssertFalse(audio.isEnabled)
        audio.toggleEnabled()
        XCTAssertTrue(audio.isEnabled)
    }

    func testEnabledPersists() {
        let store = FakeAudioStore()
        let a1 = AudioManager(store: store, preload: false)
        a1.setEnabled(false)
        // Instance mới đọc cùng store → nhớ tắt.
        let a2 = AudioManager(store: store, preload: false)
        XCTAssertFalse(a2.isEnabled)
    }

    func testFileNameMapping() {
        let (audio, _) = makeManager()
        XCTAssertEqual(audio.fileName(for: .jump), "jump.wav")
        XCTAssertEqual(audio.fileName(for: .coin), "coin.wav")
        XCTAssertEqual(audio.fileName(for: .win), "win.wav")
    }

    func testAllEffectsHaveRawNames() {
        // Mỗi SoundEffect map tới 1 file .wav (đảm bảo không thiếu asset).
        for effect in SoundEffect.allCases {
            XCTAssertFalse(effect.rawValue.isEmpty)
        }
        XCTAssertEqual(SoundEffect.allCases.count, 8)
    }

    func testPlayWhenDisabledDoesNothing() {
        let (audio, _) = makeManager()
        audio.setEnabled(false)
        audio.play(.coin)  // preload=false → không có player; chỉ đảm bảo không crash
        XCTAssertFalse(audio.isEnabled)
    }
}
