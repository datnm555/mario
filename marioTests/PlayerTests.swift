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

    // MARK: - Game feel (coyote time, jump buffer, variable jump height)

    func testCoyoteTimeAllowsLateJump() {
        let p = Player()
        p.isOnGround = true
        p.update(input: InputState(), dt: 1.0 / 60)   // nạp coyote credit
        p.isOnGround = false                           // vừa rời mép
        var jump = InputState(); jump.jumpHeld = true
        p.update(input: jump, dt: 0.05)                // 0.05s sau, vẫn trong coyote window
        XCTAssertGreaterThan(p.physicsBody!.velocity.dy, 0, "Nhảy được ngay sau khi rời mép")
    }

    func testNoJumpAfterCoyoteExpires() {
        let p = Player()
        p.isOnGround = true
        p.update(input: InputState(), dt: 1.0 / 60)
        p.isOnGround = false
        p.update(input: InputState(), dt: 0.2)         // quá coyote window
        var jump = InputState(); jump.jumpHeld = true
        p.update(input: jump, dt: 0.05)
        XCTAssertEqual(p.physicsBody!.velocity.dy, 0, "Hết coyote → không nhảy")
    }

    func testJumpBufferTriggersOnLanding() {
        let p = Player()
        p.isOnGround = false
        var jump = InputState(); jump.jumpHeld = true
        p.update(input: jump, dt: 1.0 / 60)            // bấm sớm khi còn trên không
        XCTAssertEqual(p.physicsBody!.velocity.dy, 0, "Chưa chạm đất thì chưa nhảy")
        p.isOnGround = true
        p.update(input: jump, dt: 0.05)                // chạm đất, buffer vẫn còn → nhảy
        XCTAssertGreaterThan(p.physicsBody!.velocity.dy, 0, "Buffer kích hoạt khi vừa chạm đất")
    }

    func testVariableJumpHeightCut() {
        let p = Player()
        p.isOnGround = true
        var jump = InputState(); jump.jumpHeld = true
        p.update(input: jump, dt: 1.0 / 60)            // nhảy full lực
        let full = p.physicsBody!.velocity.dy
        p.update(input: InputState(), dt: 1.0 / 60)    // thả nút khi đang lên → cắt
        XCTAssertLessThan(p.physicsBody!.velocity.dy, full, "Thả sớm → nhảy thấp hơn")
        XCTAssertGreaterThan(p.physicsBody!.velocity.dy, 0)
    }
}
