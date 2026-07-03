import SpriteKit

/// Hoa lửa: pickup đứng yên. Chạm player → lên cấp fire (bắn được).
final class FireFlower: SKSpriteNode {

    static let bodySize = CGSize(width: 24, height: 24)
    private(set) var collected = false

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.98, green: 0.55, blue: 0.15, alpha: 1),
                   size: FireFlower.bodySize)
        name = "fireflower"
        zPosition = 6
        setupPhysics()
        pulse()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.powerup
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    private func pulse() {
        let up = SKAction.scale(to: 1.15, duration: 0.5)
        up.timingMode = .easeInEaseOut
        run(.repeatForever(.sequence([up, up.reversed()])))
    }

    func collect() -> Bool {
        guard !collected else { return false }
        collected = true
        physicsBody = nil
        run(.sequence([.scale(to: 1.5, duration: 0.12), .fadeOut(withDuration: 0.12), .removeFromParent()]))
        return true
    }
}
