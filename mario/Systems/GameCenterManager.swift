import GameKit

/// Bọc Game Center: authenticate + submit best-time mỗi màn lên leaderboard.
/// Sprint 3 = interface + submit an toàn (no-op nếu chưa auth / chưa cấu hình ASC).
/// Sprint 4 sẽ bật thật (entitlement + App Store Connect leaderboard IDs).
final class GameCenterManager {

    static let shared = GameCenterManager()

    private(set) var isAuthenticated = false

    /// ID leaderboard theo màn (khớp cấu hình ASC ở Sprint 4).
    func leaderboardID(for level: Int) -> String { "time_level_\(level)" }

    /// Quy đổi thời gian (giây) → điểm leaderboard (centigiây, nhỏ = nhanh = tốt).
    func scoreValue(fromTime seconds: Double) -> Int {
        max(0, Int((seconds * 100).rounded()))
    }

    /// Đăng nhập Game Center. Trên simulator/chưa cấu hình → im lặng không auth.
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, _ in
            self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
        }
    }

    /// Gửi best-time lên leaderboard. No-op nếu chưa đăng nhập.
    func submit(time seconds: Double, level: Int) {
        guard isAuthenticated else { return }
        let score = scoreValue(fromTime: seconds)
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [leaderboardID(for: level)]) { _ in }
    }
}
