import SpriteKit

/// Nấm lớn: pickup di chuyển ngang (như Mario). Chạm player → grow.
final class Mushroom: SKSpriteNode {

    static let bodySize = CGSize(width: 26, height: 26)
    private let walkSpeed: CGFloat = 45
    private var direction: CGFloat = 1
    private(set) var collected = false

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.90, green: 0.35, blue: 0.30, alpha: 1),
                   size: Mushroom.bodySize)
        name = "mushroom"
        zPosition = 6
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
        body.categoryBitMask = PhysicsCategory.powerup
        body.collisionBitMask = PhysicsCategory.solid
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    func update(dt: TimeInterval) {
        guard !collected, let body = physicsBody else { return }
        if abs(body.velocity.dx) < walkSpeed * 0.25 { direction *= -1 } // chạm tường → quay đầu
        body.velocity.dx = direction * walkSpeed
    }

    /// Trả về true nếu lần đầu nhặt.
    func collect() -> Bool {
        guard !collected else { return false }
        collected = true
        physicsBody = nil
        run(.sequence([.fadeOut(withDuration: 0.15), .removeFromParent()]))
        return true
    }
}
