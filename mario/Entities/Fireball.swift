import SpriteKit

/// Đạn lửa player bắn ra: bay ngang, nảy nhẹ, giết enemy, tự huỷ khi chạm tường
/// hoặc hết thời gian sống.
final class Fireball: SKSpriteNode {

    static let bodySize = CGSize(width: 12, height: 12)
    private let flySpeed: CGFloat = 340
    private let lifetime: TimeInterval = 2.5
    private(set) var isSpent = false

    /// direction: +1 phải, -1 trái.
    init(direction: CGFloat) {
        super.init(texture: nil,
                   color: SKColor(red: 1.0, green: 0.55, blue: 0.10, alpha: 1),
                   size: Fireball.bodySize)
        name = "fireball"
        zPosition = 8
        setupPhysics(direction: direction)
        run(.sequence([.wait(forDuration: lifetime), .run { [weak self] in self?.despawn() }]))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics(direction: CGFloat) {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2)
        body.isDynamic = true
        body.allowsRotation = false
        body.restitution = 0.6           // nảy nhẹ khi chạm đất
        body.friction = 0
        body.linearDamping = 0
        body.mass = 0.05
        body.categoryBitMask = PhysicsCategory.projectile
        body.collisionBitMask = PhysicsCategory.solid
        body.contactTestBitMask = PhysicsCategory.enemy
        body.velocity = CGVector(dx: direction * flySpeed, dy: -50)
        physicsBody = body
    }

    /// Giữ tốc độ ngang không đổi (nảy dọc nhưng vẫn bay tới).
    func update(dt: TimeInterval) {
        guard !isSpent, let body = physicsBody else { return }
        let dir: CGFloat = body.velocity.dx >= 0 ? 1 : -1
        body.velocity.dx = dir * flySpeed
    }

    func despawn() {
        guard !isSpent else { return }
        isSpent = true
        physicsBody = nil
        run(.sequence([.scale(to: 1.6, duration: 0.08), .fadeOut(withDuration: 0.08), .removeFromParent()]))
    }
}
