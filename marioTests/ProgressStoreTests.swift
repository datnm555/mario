import XCTest
@testable import mario

/// In-memory store thay UserDefaults để test không đụng disk.
private final class FakeStore: KeyValueStore {
    var dict: [String: Any] = [:]
    func object(forKey defaultName: String) -> Any? { dict[defaultName] }
    func set(_ value: Any?, forKey defaultName: String) { dict[defaultName] = value }
    func removeObject(forKey defaultName: String) { dict[defaultName] = nil }
}

final class ProgressStoreTests: XCTestCase {

    private func makeStore() -> (ProgressStore, FakeStore) {
        let fake = FakeStore()
        return (ProgressStore(store: fake, totalLevels: 5), fake)
    }

    func testFreshProgress() {
        let (p, _) = makeStore()
        XCTAssertEqual(p.maxLevelCleared, 0)
        XCTAssertEqual(p.totalCoins, 0)
    }

    func testOnlyFirstLevelUnlockedInitially() {
        let (p, _) = makeStore()
        XCTAssertTrue(p.isUnlocked(level: 1))
        XCTAssertFalse(p.isUnlocked(level: 2))
    }

    func testMarkClearedUnlocksNext() {
        let (p, _) = makeStore()
        p.markCleared(level: 1)
        XCTAssertEqual(p.maxLevelCleared, 1)
        XCTAssertTrue(p.isUnlocked(level: 2))
        XCTAssertFalse(p.isUnlocked(level: 3))
    }

    func testMarkClearedNeverDecreases() {
        let (p, _) = makeStore()
        p.markCleared(level: 3)
        p.markCleared(level: 1)   // qua lại màn cũ không tụt tiến độ
        XCTAssertEqual(p.maxLevelCleared, 3)
    }

    func testMarkClearedIgnoresOutOfRange() {
        let (p, _) = makeStore()
        p.markCleared(level: 0)
        p.markCleared(level: 99)
        XCTAssertEqual(p.maxLevelCleared, 0)
    }

    func testUnlockOutOfRange() {
        let (p, _) = makeStore()
        p.markCleared(level: 5)
        XCTAssertFalse(p.isUnlocked(level: 6), "Không có màn 6")
        XCTAssertFalse(p.isUnlocked(level: 0))
    }

    func testAddCoinsAccumulates() {
        let (p, _) = makeStore()
        p.addCoins(3)
        p.addCoins(2)
        XCTAssertEqual(p.totalCoins, 5)
    }

    func testAddCoinsIgnoresNonPositive() {
        let (p, _) = makeStore()
        p.addCoins(0)
        p.addCoins(-5)
        XCTAssertEqual(p.totalCoins, 0)
    }

    func testBestTimeKeepsFastest() {
        let (p, _) = makeStore()
        XCTAssertNil(p.bestTime(level: 1))
        p.recordTime(30.0, level: 1)
        XCTAssertEqual(p.bestTime(level: 1), 30.0)
        p.recordTime(25.0, level: 1)         // nhanh hơn → cập nhật
        XCTAssertEqual(p.bestTime(level: 1), 25.0)
        p.recordTime(40.0, level: 1)         // chậm hơn → giữ nguyên
        XCTAssertEqual(p.bestTime(level: 1), 25.0)
    }

    func testReset() {
        let (p, _) = makeStore()
        p.markCleared(level: 4)
        p.addCoins(10)
        p.recordTime(12.0, level: 2)
        p.reset()
        XCTAssertEqual(p.maxLevelCleared, 0)
        XCTAssertEqual(p.totalCoins, 0)
        XCTAssertNil(p.bestTime(level: 2))
    }

    func testPersistsAcrossInstances() {
        let fake = FakeStore()
        let p1 = ProgressStore(store: fake, totalLevels: 5)
        p1.markCleared(level: 2)
        p1.addCoins(7)
        // Instance mới đọc cùng store → giữ tiến độ.
        let p2 = ProgressStore(store: fake, totalLevels: 5)
        XCTAssertEqual(p2.maxLevelCleared, 2)
        XCTAssertEqual(p2.totalCoins, 7)
    }
}
