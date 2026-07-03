import SpriteKit

/// Nút bấm dùng chung cho các menu: nền bo góc + label, có tên để hit-test.
final class ButtonNode: SKNode {

    let id: String
    private let background: SKShapeNode
    private let label: SKLabelNode
    private(set) var isEnabled: Bool = true

    init(id: String, text: String, size: CGSize,
         fill: SKColor = SKColor(red: 0.20, green: 0.45, blue: 0.85, alpha: 1)) {
        self.id = id
        background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = fill
        background.strokeColor = SKColor.white.withAlphaComponent(0.6)
        background.lineWidth = 2
        label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = min(size.height * 0.42, 30)
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        super.init()
        name = "button:\(id)"
        addChild(background)
        addChild(label)

        // Accessibility: VoiceOver đọc nhãn nút.
        isAccessibilityElement = true
        accessibilityLabel = text
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.4
    }

    func setText(_ text: String) {
        label.text = text
        accessibilityLabel = text
    }

    /// Nhấp nháy nhẹ khi bấm.
    func flash() {
        run(.sequence([.scale(to: 0.92, duration: 0.06), .scale(to: 1.0, duration: 0.08)]))
    }
}

/// Tiện ích tìm ButtonNode được chạm (node hoặc tổ tiên có tên "button:").
extension SKScene {
    func tappedButton(at point: CGPoint) -> ButtonNode? {
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let n = current {
                if let button = n as? ButtonNode, button.isEnabled { return button }
                current = n.parent
            }
        }
        return nil
    }
}
