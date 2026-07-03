import XCTest
import SpriteKit
@testable import mario

final class EnemyTests: XCTestCase {

    // MARK: - Goomba

    func testGoombaStartsAlive() {
        let e = GoombaEnemy()
        XCTAssertFalse(e.isDead)
        XCTAssertNotNil(e.physicsBody)
        XCTAssertEqual(e.kind, .goomba)
        XCTAssertFalse(e.isSlidingShell)
    }

    func testGoombaStompKills() {
        let e = GoombaEnemy()
        let bounce = e.onStompFromAbove()
        XCTAssertTrue(bounce, "Giẫm Goomba → player nảy")
        XCTAssertTrue(e.isDead)
    }

    func testGoombaSideContactKillsPlayer() {
        let e = GoombaEnemy()
        XCTAssertTrue(e.onSideContact(playerX: -100), "Chạm hông Goomba → player chết")
    }

    func testGoombaShellHitKills() {
        let e = GoombaEnemy()
        e.onShellHit()
        XCTAssertTrue(e.isDead)
    }

    func testGoombaWalksLeftByDefault() {
        let e = GoombaEnemy()
        e.position = .zero
        e.didSpawn()
        e.physicsBody!.velocity.dx = -55
        e.update(dt: 1.0 / 60)
        XCTAssertLessThan(e.physicsBody!.velocity.dx, 0)
    }

    func testGoombaReversesAtBound() {
        let e = GoombaEnemy()
        e.position = .zero
        e.didSpawn()
        e.physicsBody!.velocity.dx = -55
        e.position = CGPoint(x: -200, y: 0)
        e.update(dt: 1.0 / 60)
        XCTAssertGreaterThan(e.physicsBody!.velocity.dx, 0)
    }

    // MARK: - Koopa (shell mechanic)

    func testKoopaStompBecomesShellNotDead() {
        let k = KoopaEnemy()
        let bounce = k.onStompFromAbove()
        XCTAssertTrue(bounce)
        XCTAssertFalse(k.isDead, "Giẫm Koopa → thành mai, chưa chết")
        XCTAssertFalse(k.isSlidingShell, "Mai vừa tạo còn đứng yên")
    }

    func testKoopaWalkingSideContactKillsPlayer() {
        let k = KoopaEnemy()
        XCTAssertTrue(k.onSideContact(playerX: -100), "Koopa đang đi → chạm hông player chết")
    }

    func testKoopaShellKickedStartsSliding() {
        let k = KoopaEnemy()
        k.position = .zero
        _ = k.onStompFromAbove()                       // → shell
        let dies = k.onSideContact(playerX: -50)       // player bên trái → đá sang phải
        XCTAssertFalse(dies, "Đá mai → player an toàn")
        XCTAssertTrue(k.isSlidingShell)
        XCTAssertGreaterThan(k.physicsBody!.velocity.dx, 0, "Mai trượt ra xa player (sang phải)")
    }

    func testKoopaSlidingShellKillsPlayerOnSide() {
        let k = KoopaEnemy()
        k.position = .zero
        _ = k.onStompFromAbove()
        _ = k.onSideContact(playerX: -50)              // → sliding
        XCTAssertTrue(k.onSideContact(playerX: -50), "Chạy vào mai đang trượt → player chết")
    }

    func testKoopaStompSlidingShellStopsIt() {
        let k = KoopaEnemy()
        k.position = .zero
        _ = k.onStompFromAbove()
        _ = k.onSideContact(playerX: -50)              // sliding
        XCTAssertTrue(k.isSlidingShell)
        let bounce = k.onStompFromAbove()              // giẫm lại → dừng
        XCTAssertTrue(bounce)
        XCTAssertFalse(k.isSlidingShell, "Giẫm mai đang trượt → dừng")
    }

    func testKoopaShellHitKills() {
        let k = KoopaEnemy()
        k.onShellHit()
        XCTAssertTrue(k.isDead)
    }

    // MARK: - Flying

    func testFlyingStartsAliveKinematic() {
        let f = FlyingEnemy()
        XCTAssertFalse(f.isDead)
        XCTAssertEqual(f.kind, .flying)
        XCTAssertEqual(f.physicsBody?.isDynamic, false, "Bay = kinematic, không rơi")
    }

    func testFlyingStompKills() {
        let f = FlyingEnemy()
        XCTAssertTrue(f.onStompFromAbove())
        XCTAssertTrue(f.isDead)
    }

    func testFlyingSideContactKillsPlayer() {
        let f = FlyingEnemy()
        XCTAssertTrue(f.onSideContact(playerX: 0))
    }

    func testFlyingMovesAlongPath() {
        let f = FlyingEnemy()
        f.position = CGPoint(x: 100, y: 100)
        f.didSpawn()
        f.update(dt: 0.1)
        XCTAssertLessThan(f.position.x, 100, "Bắt đầu bay sang trái")
    }

    func testDeadEnemyStopsUpdating() {
        let e = GoombaEnemy()
        e.didSpawn()
        e.onShellHit()
        e.update(dt: 1.0 / 60)   // dead → no-op, không crash
        XCTAssertTrue(e.isDead)
    }
}
