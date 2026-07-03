import CoreGraphics

/// Hằng số dùng chung toàn game (độ phân giải thiết kế, số màn).
enum GameConfig {
    static let designSize = CGSize(width: 1024, height: 576)
    static let totalLevels = 5

    /// Tên file JSON của màn theo index 1-based.
    static func levelName(for index: Int) -> String { "level-1-\(index)" }
}
