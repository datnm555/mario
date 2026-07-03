import SpriteKit

/// Các loại enemy — dùng khi load level (legend) và khi spawn.
enum EnemyKind {
    case goomba   // 'E'
    case koopa    // 'K'
    case flying   // 'Y'
}

/// Giao diện chung cho mọi enemy → GameScene xử lý đồng nhất, dễ thêm loại mới.
protocol Enemy: AnyObject {
    var node: SKSpriteNode { get }
    var isDead: Bool { get }
    var kind: EnemyKind { get }

    func update(dt: TimeInterval)

    /// Gọi ngay sau khi đặt vị trí (chốt tâm patrol / cao độ bay).
    func didSpawn()

    /// Player giẫm từ trên đầu. Trả về: player có nảy lên không.
    func onStompFromAbove() -> Bool

    /// Player chạm từ hông (truyền playerX để biết hướng). Trả về: player có CHẾT không.
    func onSideContact(playerX: CGFloat) -> Bool

    /// Bị mai rùa (shell) đang trượt tông trúng → enemy này chết.
    func onShellHit()

    /// Enemy này có đang là shell trượt (giết enemy khác khi chạm) không.
    var isSlidingShell: Bool { get }
}

extension Enemy {
    func didSpawn() {}
    var isSlidingShell: Bool { false }
}

/// Hiệu ứng chết chung: dẹp lép rồi mờ dần rồi biến mất.
func squashAndRemove(_ node: SKSpriteNode) {
    node.physicsBody = nil
    let squash = SKAction.scaleY(to: 0.2, duration: 0.08)
    let fade = SKAction.fadeOut(withDuration: 0.25)
    node.run(.sequence([squash, fade, .removeFromParent()]))
}

// MARK: - Goomba

/// Goomba-like: đi patrol qua lại, đổi hướng khi chạm tường/biên.
final class GoombaEnemy: SKSpriteNode, Enemy {

    private let walkSpeed: CGFloat = 55
    private var direction: CGFloat = -1
    private(set) var isDead = false

    private var originX: CGFloat = 0
    private let patrolRange: CGFloat = 96

    static let bodySize = CGSize(width: 28, height: 26)

    var node: SKSpriteNode { self }
    var kind: EnemyKind { .goomba }

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.55, green: 0.34, blue: 0.16, alpha: 1),
                   size: GoombaEnemy.bodySize)
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
        body.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        physicsBody = body
    }

    func didSpawn() { originX = position.x }

    func update(dt: TimeInterval) {
        guard !isDead, let body = physicsBody else { return }
        if direction < 0 && position.x <= originX - patrolRange {
            direction = 1
        } else if direction > 0 && position.x >= originX + patrolRange {
            direction = -1
        }
        if abs(body.velocity.dx) < walkSpeed * 0.25 {
            direction *= -1
        }
        body.velocity.dx = direction * walkSpeed
    }

    func reverse() { direction *= -1 }

    func onStompFromAbove() -> Bool {
        stomp()
        return true
    }

    func onSideContact(playerX: CGFloat) -> Bool {
        true // chạm hông Goomba → player chết
    }

    func onShellHit() { stomp() }

    private func stomp() {
        guard !isDead else { return }
        isDead = true
        squashAndRemove(self)
    }
}
