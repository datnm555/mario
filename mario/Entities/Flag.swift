import SpriteKit

/// Cờ kết thúc màn: chạm vào → win. Placeholder cột xanh + cờ.
final class Flag: SKSpriteNode {

    static let poleSize = CGSize(width: 8, height: 180)
    private(set) var reached = false

    init() {
        super.init(texture: nil,
                   color: SKColor(red: 0.30, green: 0.75, blue: 0.35, alpha: 1),
                   size: Flag.poleSize)
        name = "flag"
        zPosition = 4
        setupPhysics()
        addFlagPiece()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.flag
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    private func addFlagPiece() {
        let piece = SKSpriteNode(color: SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),
                                 size: CGSize(width: 30, height: 22))
        piece.position = CGPoint(x: 19, y: Flag.poleSize.height / 2 - 16)
        addChild(piece)
    }

    func reach() {
        guard !reached else { return }
        reached = true
    }
}
