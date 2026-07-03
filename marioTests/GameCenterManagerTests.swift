import XCTest
@testable import mario

final class GameCenterManagerTests: XCTestCase {

    private let gc = GameCenterManager.shared

    func testLeaderboardIDPerLevel() {
        XCTAssertEqual(gc.leaderboardID(for: 1), "time_level_1")
        XCTAssertEqual(gc.leaderboardID(for: 5), "time_level_5")
    }

    func testScoreValueIsCentiseconds() {
        XCTAssertEqual(gc.scoreValue(fromTime: 30.5), 3050)
        XCTAssertEqual(gc.scoreValue(fromTime: 0), 0)
    }

    func testFasterTimeGivesLowerScore() {
        // Thời gian nhỏ hơn (nhanh hơn) → điểm nhỏ hơn (leaderboard tăng dần = xếp trên).
        XCTAssertLessThan(gc.scoreValue(fromTime: 12.3), gc.scoreValue(fromTime: 20.0))
    }

    func testNotAuthenticatedByDefaultInTests() {
        // Chưa authenticate (simulator/không config) → submit là no-op an toàn.
        XCTAssertFalse(gc.isAuthenticated)
        gc.submit(time: 15.0, level: 1)   // không crash
    }
}
