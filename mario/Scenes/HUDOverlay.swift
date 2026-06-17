import SpriteKit

/// HUD tối thiểu: số coin + số mạng. Child của camera → dính màn hình.
final class HUDOverlay: SKNode {

    private let coinLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    func setup(designSize: CGSize) {
        removeAllChildren()
        let halfW = designSize.width / 2
        let halfH = designSize.height / 2
        let margin: CGFloat = 24

        coinLabel.fontSize = 24
        coinLabel.fontColor = .white
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.verticalAlignmentMode = .top
        coinLabel.position = CGPoint(x: -halfW + margin, y: halfH - margin)
        coinLabel.zPosition = 1000
        addChild(coinLabel)

        livesLabel.fontSize = 24
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.verticalAlignmentMode = .top
        livesLabel.position = CGPoint(x: halfW - margin, y: halfH - margin)
        livesLabel.zPosition = 1000
        addChild(livesLabel)
    }

    func refresh(coins: Int, lives: Int) {
        coinLabel.text = "🪙 \(coins)"
        livesLabel.text = "♥ \(lives)"
    }
}
