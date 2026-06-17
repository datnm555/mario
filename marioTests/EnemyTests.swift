import XCTest
import SpriteKit
@testable import mario

final class EnemyTests: XCTestCase {

    func testStartsAlive() {
        let e = GoombaEnemy()
        XCTAssertFalse(e.isDead)
        XCTAssertNotNil(e.physicsBody)
    }

    func testStompKills() {
        let e = GoombaEnemy()
        e.stomp()
        XCTAssertTrue(e.isDead)
        XCTAssertNil(e.physicsBody, "Chết → bỏ physics để không còn va chạm")
    }

    func testStompIsIdempotent() {
        let e = GoombaEnemy()
        e.stomp()
        e.stomp() // gọi lần 2 không lỗi, vẫn dead
        XCTAssertTrue(e.isDead)
    }

    func testWalksInADirection() {
        let e = GoombaEnemy()
        e.position = .zero
        e.anchorPatrol()
        // Không bị chặn (set velocity khác 0) và trong biên → giữ hướng đi.
        e.physicsBody!.velocity.dx = -55
        e.update(dt: 1.0 / 60)
        XCTAssertLessThan(e.physicsBody!.velocity.dx, 0, "Đi sang trái mặc định")
    }

    func testReversesAtPatrolBound() {
        let e = GoombaEnemy()
        e.position = .zero
        e.anchorPatrol()
        // Đẩy ra ngoài biên trái (patrolRange = 96) trong khi đang đi trái.
        e.physicsBody!.velocity.dx = -55
        e.position = CGPoint(x: -200, y: 0)
        e.update(dt: 1.0 / 60)
        XCTAssertGreaterThan(e.physicsBody!.velocity.dx, 0, "Chạm biên → quay đầu sang phải")
    }

    func testReversesWhenBlocked() {
        let e = GoombaEnemy()
        e.position = .zero
        e.anchorPatrol()
        // velocity ~ 0 = bị tường chặn → đảo hướng.
        e.physicsBody!.velocity.dx = 0
        e.update(dt: 1.0 / 60)
        XCTAssertGreaterThan(e.physicsBody!.velocity.dx, 0, "Bị chặn → đảo hướng")
    }

    func testDeadStopsUpdating() {
        let e = GoombaEnemy()
        e.anchorPatrol()
        e.stomp()
        e.update(dt: 1.0 / 60) // physicsBody nil → không crash, no-op
        XCTAssertNil(e.physicsBody)
    }
}
