import SpriteKit

/// Koopa-like với cơ chế mai (shell):
/// - walking: đi patrol như Goomba.
/// - shell (đứng yên): giẫm → nảy; chạm hông → đá cho trượt.
/// - sliding: mai trượt nhanh, giết enemy khác; chạm hông player → chết; giẫm → dừng lại.
final class KoopaEnemy: SKSpriteNode, Enemy {

    private enum Mode { case walking, shell, sliding }

    private let walkSpeed: CGFloat = 48
    private let slideSpeed: CGFloat = 260
    private var direction: CGFloat = -1
    private var mode: Mode = .walking
    private(set) var isDead = false

    private var originX: CGFloat = 0
    private let patrolRange: CGFloat = 110

    static let bodySize = CGSize(width: 28, height: 32)
    private static let shellHeight: CGFloat = 22

    var node: SKSpriteNode { self }
    var kind: EnemyKind { .koopa }
    var isSlidingShell: Bool { mode == .sliding }

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.20, green: 0.60, blue: 0.30, alpha: 1),
                   size: KoopaEnemy.bodySize)
        name = "enemy"
        zPosition = 9
        setupPhysics()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.allowsRotation = false
        body.restitution = 0
        body.friction = 0
        body.linearDamping = 0
        body.mass = 0.2
        body.categoryBitMask = PhysicsCategory.enemy
        body.collisionBitMask = PhysicsCategory.solid | PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        physicsBody = body
    }

    func didSpawn() { originX = position.x }

    func update(dt: TimeInterval) {
        guard !isDead, let body = physicsBody else { return }
        switch mode {
        case .walking:
            if direction < 0 && position.x <= originX - patrolRange { direction = 1 }
            else if direction > 0 && position.x >= originX + patrolRange { direction = -1 }
            if abs(body.velocity.dx) < walkSpeed * 0.25 { direction *= -1 }
            body.velocity.dx = direction * walkSpeed
        case .shell:
            body.velocity.dx = 0
        case .sliding:
            // Trượt; gặp tường (đứng yên) thì dội lại.
            if abs(body.velocity.dx) < slideSpeed * 0.25 { direction *= -1 }
            body.velocity.dx = direction * slideSpeed
        }
    }

    func onStompFromAbove() -> Bool {
        switch mode {
        case .walking, .sliding:
            enterShell()      // đi/đang trượt → dừng thành mai
        case .shell:
            break             // giẫm mai đứng yên: chỉ nảy
        }
        return true
    }

    func onSideContact(playerX: CGFloat) -> Bool {
        switch mode {
        case .walking:
            return true       // chạm hông koopa đang đi → player chết
        case .shell:
            kick(awayFrom: playerX)
            return false      // đá mai → player an toàn
        case .sliding:
            return true       // chạy vào mai đang trượt → player chết
        }
    }

    func onShellHit() { die() }

    // MARK: - State transitions

    private func enterShell() {
        mode = .shell
        physicsBody?.velocity.dx = 0
        // Dẹp chiều cao thành mai.
        size.height = KoopaEnemy.shellHeight
        color = SKColor(red: 0.15, green: 0.45, blue: 0.22, alpha: 1)
    }

    private func kick(awayFrom playerX: CGFloat) {
        direction = position.x >= playerX ? 1 : -1
        mode = .sliding
        physicsBody?.velocity.dx = direction * slideSpeed  // set ngay để update không lầm là "bị chặn"
    }

    private func die() {
        guard !isDead else { return }
        isDead = true
        squashAndRemove(self)
    }
}
