import SpriteKit

/// Enemy bay: patrol ngang quanh điểm spawn + dao động dọc theo sin.
/// Kinematic (không chịu trọng lực) — di chuyển bằng cách set position mỗi frame.
/// Vẫn phát hiện va chạm với player (physicsBody non-dynamic).
final class FlyingEnemy: SKSpriteNode, Enemy {

    private let horizontalSpeed: CGFloat = 70
    private let horizontalRange: CGFloat = 140
    private let verticalAmplitude: CGFloat = 40
    private let verticalFrequency: CGFloat = 2.0   // rad/giây

    private var direction: CGFloat = -1
    private var originX: CGFloat = 0
    private var originY: CGFloat = 0
    private var phase: TimeInterval = 0
    private(set) var isDead = false

    static let bodySize = CGSize(width: 30, height: 22)

    var node: SKSpriteNode { self }
    var kind: EnemyKind { .flying }

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.75, green: 0.30, blue: 0.65, alpha: 1),
                   size: FlyingEnemy.bodySize)
        name = "enemy"
        zPosition = 9
        setupPhysics()
        addWings()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false                 // kinematic: tự điều khiển đường bay
        body.categoryBitMask = PhysicsCategory.enemy
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    private func addWings() {
        let wing = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.85),
                                size: CGSize(width: 10, height: 6))
        wing.position = CGPoint(x: -size.width / 2 - 3, y: 4)
        addChild(wing)
        wing.run(.repeatForever(.sequence([
            .rotate(toAngle: 0.5, duration: 0.15),
            .rotate(toAngle: -0.3, duration: 0.15)
        ])))
    }

    func didSpawn() {
        originX = position.x
        originY = position.y
    }

    func update(dt: TimeInterval) {
        guard !isDead else { return }
        phase += dt

        // Ngang: patrol qua lại quanh originX.
        var x = position.x + direction * horizontalSpeed * CGFloat(dt)
        if x <= originX - horizontalRange { x = originX - horizontalRange; direction = 1 }
        else if x >= originX + horizontalRange { x = originX + horizontalRange; direction = -1 }

        // Dọc: dao động sin.
        let y = originY + verticalAmplitude * CGFloat(sin(Double(verticalFrequency) * phase))
        position = CGPoint(x: x, y: y)
    }

    func onStompFromAbove() -> Bool {
        die()
        return true
    }

    func onSideContact(playerX: CGFloat) -> Bool {
        true // chạm hông → player chết
    }

    func onShellHit() { die() }

    private func die() {
        guard !isDead else { return }
        isDead = true
        squashAndRemove(self)
    }
}
