import Foundation

/// Kho key-value tối giản để inject được (test dùng in-memory thay UserDefaults).
protocol KeyValueStore: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: KeyValueStore {}

/// Lưu tiến độ chơi: màn cao nhất đã qua, tổng coin, best-time mỗi màn.
/// Logic thuần → test bằng cách inject `KeyValueStore` giả.
final class ProgressStore {

    /// Instance dùng chung cho app (UserDefaults thật). Test dùng init inject.
    static let shared = ProgressStore()

    private enum Key {
        static let maxLevelCleared = "progress.maxLevelCleared"
        static let totalCoins = "progress.totalCoins"
        static func bestTime(_ level: Int) -> String { "progress.bestTime.\(level)" }
    }

    private let store: KeyValueStore
    let totalLevels: Int

    init(store: KeyValueStore = UserDefaults.standard, totalLevels: Int = 5) {
        self.store = store
        self.totalLevels = totalLevels
    }

    // MARK: - Level progress

    /// Màn cao nhất đã hoàn thành (0 = chưa qua màn nào). 1-indexed.
    var maxLevelCleared: Int {
        (store.object(forKey: Key.maxLevelCleared) as? Int) ?? 0
    }

    /// Đánh dấu qua màn; chỉ tăng, không tụt.
    func markCleared(level: Int) {
        guard level >= 1, level <= totalLevels else { return }
        if level > maxLevelCleared {
            store.set(level, forKey: Key.maxLevelCleared)
        }
    }

    /// Màn 1 luôn mở; màn n mở khi đã qua màn n-1.
    func isUnlocked(level: Int) -> Bool {
        guard level >= 1, level <= totalLevels else { return false }
        return level <= maxLevelCleared + 1
    }

    // MARK: - Coins

    var totalCoins: Int {
        (store.object(forKey: Key.totalCoins) as? Int) ?? 0
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        store.set(totalCoins + amount, forKey: Key.totalCoins)
    }

    // MARK: - Best time (giây), chuẩn bị cho Game Center Sprint 3

    func bestTime(level: Int) -> Double? {
        store.object(forKey: Key.bestTime(level)) as? Double
    }

    /// Ghi nhận thời gian; chỉ giữ giá trị nhỏ hơn (nhanh hơn).
    func recordTime(_ seconds: Double, level: Int) {
        guard seconds > 0 else { return }
        if let current = bestTime(level: level), current <= seconds { return }
        store.set(seconds, forKey: Key.bestTime(level))
    }

    // MARK: - Reset

    func reset() {
        store.removeObject(forKey: Key.maxLevelCleared)
        store.removeObject(forKey: Key.totalCoins)
        for level in 1...max(1, totalLevels) {
            store.removeObject(forKey: Key.bestTime(level))
        }
    }
}
