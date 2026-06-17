import SpriteKit

/// Giao diện chung cho enemy → dễ thêm loại mới (sprint 2: flying, koopa...).
protocol Enemy: AnyObject {
    var node: SKSpriteNode { get }
    func update(dt: TimeInterval)
    /// Bị player stomp → chết.
    func stomp()
    var isDead: Bool { get }
}

/// Goomba-like: đi patrol qua lại, đổi hướng khi chạm tường/mép.
final class GoombaEnemy: SKSpriteNode, Enemy {

    private let walkSpeed: CGFloat = 55
    private var direction: CGFloat = -1   // bắt đầu đi sang trái
    private(set) var isDead = false

    /// Patrol quanh điểm spawn ±patrolRange (set sau khi đặt vị trí).
    private var originX: CGFloat = 0
    private let patrolRange: CGFloat = 96

    static let bodySize = CGSize(width: 28, height: 26)

    var node: SKSpriteNode { self }

    /// Gọi sau khi đã đặt position để chốt tâm patrol.
    func anchorPatrol() {
        originX = position.x
    }

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
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.ground
        physicsBody = body
    }

    func update(dt: TimeInterval) {
        guard !isDead, let body = physicsBody else { return }
        // Đảo hướng tại biên patrol.
        if direction < 0 && position.x <= originX - patrolRange {
            direction = 1
        } else if direction > 0 && position.x >= originX + patrolRange {
            direction = -1
        }
        // Bị tường chặn (đứng yên dù đang đẩy) → quay đầu.
        if abs(body.velocity.dx) < walkSpeed * 0.25 {
            direction *= -1
        }
        body.velocity.dx = direction * walkSpeed
    }

    func reverse() {
        direction *= -1
    }

    func stomp() {
        guard !isDead else { return }
        isDead = true
        physicsBody = nil
        // Dẹp lép rồi biến mất.
        let squash = SKAction.scaleY(to: 0.2, duration: 0.08)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        run(.sequence([squash, fade, .removeFromParent()]))
    }
}
