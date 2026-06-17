import SpriteKit

/// Coin: pickup sensor (không cản đường), nhặt được → +1.
final class Coin: SKSpriteNode {

    static let bodySize = CGSize(width: 16, height: 16)
    private(set) var collected = false

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.98, green: 0.82, blue: 0.18, alpha: 1),
                   size: Coin.bodySize)
        name = "coin"
        zPosition = 5
        setupPhysics()
        idleBob()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.coin
        body.collisionBitMask = PhysicsCategory.none      // không cản
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    private func idleBob() {
        let up = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        run(.repeatForever(.sequence([up, down])))
    }

    /// Trả về true nếu lần đầu nhặt (tránh double-count).
    func collect() -> Bool {
        guard !collected else { return false }
        collected = true
        physicsBody = nil
        run(.sequence([
            .group([.scale(to: 1.6, duration: 0.12), .fadeOut(withDuration: 0.12)]),
            .removeFromParent()
        ]))
        return true
    }
}
