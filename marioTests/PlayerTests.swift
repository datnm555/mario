import XCTest
import SpriteKit
@testable import mario

final class PlayerTests: XCTestCase {

    func testStartsIdle() {
        let p = Player()
        XCTAssertEqual(p.state, .idle)
        XCTAssertFalse(p.isDead)
    }

    func testRunningRight() {
        let p = Player()
        p.isOnGround = true
        var input = InputState()
        input.rightPressed = true
        p.update(input: input, dt: 1.0 / 60)
        XCTAssertEqual(p.state, .running)
        XCTAssertGreaterThan(p.physicsBody!.velocity.dx, 0)
    }

    func testRunningLeft() {
        let p = Player()
        p.isOnGround = true
        var input = InputState()
        input.leftPressed = true
        p.update(input: input, dt: 1.0 / 60)
        XCTAssertEqual(p.state, .running)
        XCTAssertLessThan(p.physicsBody!.velocity.dx, 0)
    }

    func testIdleWhenNoInputOnGround() {
        let p = Player()
        p.isOnGround = true
        p.update(input: InputState(), dt: 1.0 / 60)
        XCTAssertEqual(p.state, .idle)
        XCTAssertEqual(p.physicsBody!.velocity.dx, 0)
    }

    func testJumpFromGround() {
        let p = Player()
        p.isOnGround = true
        var input = InputState()
        input.jumpHeld = true
        p.update(input: input, dt: 1.0 / 60)
        XCTAssertGreaterThan(p.physicsBody!.velocity.dy, 0, "Nhảy → velocity dy dương")
        XCTAssertFalse(p.isOnGround, "Rời đất sau khi nhảy")
        XCTAssertEqual(p.state, .jumping)
    }

    func testNoJumpWhenAirborne() {
        let p = Player()
        p.isOnGround = false
        p.physicsBody!.velocity.dy = 0
        var input = InputState()
        input.jumpHeld = true
        p.update(input: input, dt: 1.0 / 60)
        XCTAssertEqual(p.physicsBody!.velocity.dy, 0, "Đang trên không → không nhảy được")
    }

    func testNoDoubleJumpWhileHeld() {
        let p = Player()
        p.isOnGround = true
        var input = InputState()
        input.jumpHeld = true
        p.update(input: input, dt: 1.0 / 60)          // edge → nhảy
        let afterFirst = p.physicsBody!.velocity.dy
        // Giữ nguyên nút (không phải cạnh lên), giả lập đã chạm đất lại
        p.isOnGround = true
        p.physicsBody!.velocity.dy = 0
        p.update(input: input, dt: 1.0 / 60)           // vẫn giữ → không nhảy lại
        XCTAssertEqual(p.physicsBody!.velocity.dy, 0, "Giữ nút không tạo nhảy lặp")
        XCTAssertGreaterThan(afterFirst, 0)
    }

    func testFallingState() {
        let p = Player()
        p.isOnGround = false
        p.physicsBody!.velocity.dy = -50
        p.update(input: InputState(), dt: 1.0 / 60)
        XCTAssertEqual(p.state, .falling)
    }

    func testDie() {
        let p = Player()
        p.die()
        XCTAssertTrue(p.isDead)
        XCTAssertEqual(p.state, .dead)
    }

    func testDeadIgnoresInput() {
        let p = Player()
        p.die()
        let velBefore = p.physicsBody?.velocity.dx ?? -1
        var input = InputState()
        input.rightPressed = true
        p.update(input: input, dt: 1.0 / 60)
        // die() bỏ physicsBody categories nhưng body vẫn còn; update sớm return khi isDead.
        XCTAssertEqual(p.physicsBody?.velocity.dx ?? -1, velBefore)
    }

    func testBounce() {
        let p = Player()
        p.physicsBody!.velocity.dy = -100
        p.bounce()
        XCTAssertGreaterThan(p.physicsBody!.velocity.dy, 0)
        XCTAssertFalse(p.isOnGround)
    }
}
