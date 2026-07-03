import XCTest
import SpriteKit
@testable import mario

final class PowerupTests: XCTestCase {

    // MARK: - Player power state machine

    func testStartsSmall() {
        let p = Player()
        XCTAssertEqual(p.power, .small)
        XCTAssertFalse(p.canShoot)
    }

    func testGrowSmallToBig() {
        let p = Player()
        p.grow()
        XCTAssertEqual(p.power, .big)
    }

    func testGrowBigStaysBig() {
        let p = Player()
        p.grow()
        p.grow()
        XCTAssertEqual(p.power, .big, "Nấm khi đã big → giữ big")
    }

    func testFireFlowerMakesFire() {
        let p = Player()
        p.becomeFire()
        XCTAssertEqual(p.power, .fire)
        XCTAssertTrue(p.canShoot)
    }

    func testDamageFireToBig() {
        let p = Player()
        p.becomeFire()
        let fatal = p.takeDamage()
        XCTAssertFalse(fatal)
        XCTAssertEqual(p.power, .big)
    }

    func testDamageBigToSmall() {
        let p = Player()
        p.grow()
        let fatal = p.takeDamage()
        XCTAssertFalse(fatal)
        XCTAssertEqual(p.power, .small)
    }

    func testDamageSmallIsFatal() {
        let p = Player()
        XCTAssertTrue(p.takeDamage(), "Small trúng đòn → chết")
    }

    func testInvulnerableAfterDamage() {
        let p = Player()
        p.becomeFire()
        _ = p.takeDamage()          // fire → big, bật bất tử
        XCTAssertTrue(p.isInvulnerable)
        let second = p.takeDamage() // đang bất tử → bỏ qua
        XCTAssertFalse(second)
        XCTAssertEqual(p.power, .big, "Bất tử → không xuống cấp tiếp")
    }

    // MARK: - Shooting

    func testCannotShootWhenNotFire() {
        let p = Player()
        XCTAssertFalse(p.tryShoot())
    }

    func testShootHasCooldown() {
        let p = Player()
        p.becomeFire()
        XCTAssertTrue(p.tryShoot(), "Lần bắn đầu OK")
        XCTAssertFalse(p.tryShoot(), "Bắn ngay lại → dính cooldown")
        p.update(input: InputState(), dt: 0.5)  // chờ hết cooldown
        XCTAssertTrue(p.tryShoot(), "Hết cooldown → bắn lại được")
    }

    func testFacingUpdatesFromInput() {
        let p = Player()
        var input = InputState()
        input.leftPressed = true
        p.update(input: input, dt: 1.0 / 60)
        XCTAssertEqual(p.facing, -1)
        input.leftPressed = false
        input.rightPressed = true
        p.update(input: input, dt: 1.0 / 60)
        XCTAssertEqual(p.facing, 1)
    }

    // MARK: - Entities

    func testMushroomCollectOnce() {
        let m = Mushroom()
        XCTAssertTrue(m.collect())
        XCTAssertFalse(m.collect(), "Nhặt 2 lần → chỉ tính 1")
        XCTAssertTrue(m.collected)
    }

    func testFireFlowerCollectOnce() {
        let w = FireFlower()
        XCTAssertTrue(w.collect())
        XCTAssertFalse(w.collect())
    }

    func testFireballDirection() {
        let right = Fireball(direction: 1)
        XCTAssertGreaterThan(right.physicsBody!.velocity.dx, 0)
        let left = Fireball(direction: -1)
        XCTAssertLessThan(left.physicsBody!.velocity.dx, 0)
    }

    func testFireballDespawn() {
        let ball = Fireball(direction: 1)
        ball.despawn()
        XCTAssertTrue(ball.isSpent)
        XCTAssertNil(ball.physicsBody)
    }

    func testFireballKeepsHorizontalSpeed() {
        let ball = Fireball(direction: 1)
        ball.physicsBody!.velocity.dx = 10   // giả lập bị chậm sau va chạm
        ball.update(dt: 1.0 / 60)
        XCTAssertGreaterThan(ball.physicsBody!.velocity.dx, 100, "Update giữ tốc độ ngang")
    }
}
