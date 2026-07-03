import SpriteKit

/// Nội dung 1 block '?' nhả ra khi đập từ dưới.
enum BlockContent {
    case coin
    case mushroom
}

/// Block '?' : solid (đứng lên được), đập từ dưới lên → nhả thưởng rồi thành block rỗng.
final class QuestionBlock: SKSpriteNode {

    static let bodySize = CGSize(width: 36, height: 36)
    let content: BlockContent
    private(set) var isUsed = false
    private let label = SKLabelNode(text: "?")

    init(content: BlockContent) {
        self.content = content
        super.init(texture: nil,
                   color: SKColor(red: 0.95, green: 0.70, blue: 0.20, alpha: 1),
                   size: QuestionBlock.bodySize)
        name = "questionBlock"
        zPosition = 7
        setupPhysics()
        addLabel()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.friction = 0.2
        body.restitution = 0
        body.categoryBitMask = PhysicsCategory.block
        body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy |
                                PhysicsCategory.powerup | PhysicsCategory.projectile
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    private func addLabel() {
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
    }

    /// Đập từ dưới. Trả về nội dung nhả ra, hoặc nil nếu đã dùng rồi.
    func bump() -> BlockContent? {
        guard !isUsed else { return nil }
        isUsed = true
        color = SKColor(red: 0.5, green: 0.42, blue: 0.30, alpha: 1) // block rỗng
        label.text = ""
        // Nảy lên rồi về chỗ cũ.
        let up = SKAction.moveBy(x: 0, y: 8, duration: 0.07)
        run(.sequence([up, up.reversed()]))
        return content
    }
}
