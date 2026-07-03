import XCTest
@testable import mario

private final class FakeSettingsStore: KeyValueStore {
    var dict: [String: Any] = [:]
    func object(forKey defaultName: String) -> Any? { dict[defaultName] }
    func set(_ value: Any?, forKey defaultName: String) { dict[defaultName] = value }
    func removeObject(forKey defaultName: String) { dict[defaultName] = nil }
}

final class SettingsStoreTests: XCTestCase {

    private func make() -> (SettingsStore, FakeSettingsStore) {
        let fake = FakeSettingsStore()
        return (SettingsStore(store: fake), fake)
    }

    func testDefaults() {
        let (s, _) = make()
        XCTAssertTrue(s.audioEnabled)
        XCTAssertTrue(s.hapticEnabled)
        XCTAssertFalse(s.leftHanded)
        XCTAssertEqual(s.controlScale, .medium)
        XCTAssertEqual(s.sfxVolume, .high)
        XCTAssertEqual(s.bgmVolume, .low)
    }

    func testSetAndReadBack() {
        let (s, _) = make()
        s.audioEnabled = false
        s.hapticEnabled = false
        s.leftHanded = true
        s.controlScale = .large
        s.sfxVolume = .off
        s.bgmVolume = .high
        XCTAssertFalse(s.audioEnabled)
        XCTAssertFalse(s.hapticEnabled)
        XCTAssertTrue(s.leftHanded)
        XCTAssertEqual(s.controlScale, .large)
        XCTAssertEqual(s.sfxVolume, .off)
        XCTAssertEqual(s.bgmVolume, .high)
    }

    func testPersistsAcrossInstances() {
        let fake = FakeSettingsStore()
        let s1 = SettingsStore(store: fake)
        s1.controlScale = .small
        s1.leftHanded = true
        let s2 = SettingsStore(store: fake)
        XCTAssertEqual(s2.controlScale, .small)
        XCTAssertTrue(s2.leftHanded)
    }

    func testVolumeLevelCycleAndValue() {
        XCTAssertEqual(VolumeLevel.off.next, .low)
        XCTAssertEqual(VolumeLevel.low.next, .high)
        XCTAssertEqual(VolumeLevel.high.next, .off)
        XCTAssertEqual(VolumeLevel.off.value, 0)
        XCTAssertGreaterThan(VolumeLevel.high.value, VolumeLevel.low.value)
    }

    func testControlScaleFactorAndCycle() {
        XCTAssertLessThan(ControlScale.small.factor, ControlScale.medium.factor)
        XCTAssertLessThan(ControlScale.medium.factor, ControlScale.large.factor)
        XCTAssertEqual(ControlScale.small.next, .medium)
        XCTAssertEqual(ControlScale.large.next, .small)
    }
}

final class HapticManagerTests: XCTestCase {

    func testRespectsSettingFlag() {
        let fake = FakeSettingsStore()
        let settings = SettingsStore(store: fake)
        let haptic = HapticManager(settings: settings)
        XCTAssertTrue(haptic.isEnabled)
        settings.hapticEnabled = false
        XCTAssertFalse(haptic.isEnabled)
    }

    func testPlayDoesNotCrash() {
        let settings = SettingsStore(store: FakeSettingsStore())
        let haptic = HapticManager(settings: settings)
        haptic.play(.light)
        haptic.play(.success)
        settings.hapticEnabled = false
        haptic.play(.heavy)   // disabled → no-op
    }
}
