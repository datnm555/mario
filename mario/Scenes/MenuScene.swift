import SpriteKit

/// Màn hình tiêu đề: title + nút Play, hiển thị tổng coin đã thu.
final class MenuScene: SKScene {

    private let progress = ProgressStore.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.42, green: 0.66, blue: 0.96, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)   // gốc toạ độ ở giữa

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "SUPER SQUARE"
        title.fontSize = 64
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 120)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = "một platformer nho nhỏ"
        subtitle.fontSize = 22
        subtitle.fontColor = SKColor.white.withAlphaComponent(0.85)
        subtitle.position = CGPoint(x: 0, y: 74)
        addChild(subtitle)

        let play = ButtonNode(id: "play", text: "▶  CHƠI", size: CGSize(width: 260, height: 72))
        play.position = CGPoint(x: 0, y: -20)
        addChild(play)

        let settings = ButtonNode(id: "settings", text: "⚙  Cài đặt", size: CGSize(width: 220, height: 54),
                                  fill: SKColor(red: 0.30, green: 0.40, blue: 0.60, alpha: 1))
        settings.position = CGPoint(x: 0, y: -96)
        addChild(settings)

        let coins = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coins.text = "🪙 tổng: \(progress.totalCoins)"
        coins.fontSize = 22
        coins.fontColor = .white
        coins.position = CGPoint(x: 0, y: -140)
        addChild(coins)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first,
              let button = tappedButton(at: t.location(in: self)) else { return }
        button.flash()
        HapticManager.shared.play(.selection)
        switch button.id {
        case "play":     SceneRouter.goLevelSelect(from: self)
        case "settings": SceneRouter.goSettings(from: self)
        default:         break
        }
    }
}
