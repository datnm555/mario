import SpriteKit

/// On-screen controls: D-pad trái/phải (dưới-trái) + nút Jump (dưới-phải).
/// Là child của camera → luôn dính màn hình. Hỗ trợ đa chạm (đi + nhảy cùng lúc).
/// Emit InputState qua property `state` — không đụng Player trực tiếp.
final class TouchControls: SKNode {

    private(set) var state = InputState()

    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    private var jumpButton: SKShapeNode!

    /// touch (identity) → tên nút đang giữ.
    private var activeTouches: [ObjectIdentifier: String] = [:]

    private let buttonAlpha: CGFloat = 0.28

    /// designSize = kích thước scene (camera-space). Gốc toạ độ camera ở giữa.
    func setup(designSize: CGSize) {
        removeAllChildren()
        let halfW = designSize.width / 2
        let halfH = designSize.height / 2
        let margin: CGFloat = 28
        let r: CGFloat = 52

        leftButton = makeButton(radius: r, label: "◀")
        leftButton.position = CGPoint(x: -halfW + margin + r, y: -halfH + margin + r)
        leftButton.name = "left"
        addChild(leftButton)

        rightButton = makeButton(radius: r, label: "▶")
        rightButton.position = CGPoint(x: -halfW + margin + r * 3 + 18, y: -halfH + margin + r)
        rightButton.name = "right"
        addChild(rightButton)

        jumpButton = makeButton(radius: r + 8, label: "A")
        jumpButton.position = CGPoint(x: halfW - margin - r - 8, y: -halfH + margin + r)
        jumpButton.name = "jump"
        addChild(jumpButton)
    }

    private func makeButton(radius: CGFloat, label: String) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = SKColor.white.withAlphaComponent(buttonAlpha)
        node.strokeColor = SKColor.white.withAlphaComponent(0.5)
        node.lineWidth = 2
        node.zPosition = 1000
        let text = SKLabelNode(text: label)
        text.fontName = "AvenirNext-Bold"
        text.fontSize = radius
        text.verticalAlignmentMode = .center
        text.horizontalAlignmentMode = .center
        text.fontColor = SKColor.white.withAlphaComponent(0.85)
        node.addChild(text)
        return node
    }

    // MARK: - Touch handling (gọi từ GameScene)

    /// scenePoint: vị trí touch trong toạ độ scene.
    func touchDown(_ touch: UITouch, scenePoint: CGPoint) {
        if let name = hitButton(at: scenePoint) {
            activeTouches[ObjectIdentifier(touch)] = name
            highlight(name, on: true)
            recompute()
        }
    }

    func touchMoved(_ touch: UITouch, scenePoint: CGPoint) {
        let key = ObjectIdentifier(touch)
        let newName = hitButton(at: scenePoint)
        let oldName = activeTouches[key]
        if newName != oldName {
            if let old = oldName { highlight(old, on: false) }
            if let new = newName {
                activeTouches[key] = new
                highlight(new, on: true)
            } else {
                activeTouches[key] = nil
            }
            recompute()
        }
    }

    func touchUp(_ touch: UITouch) {
        let key = ObjectIdentifier(touch)
        if let name = activeTouches[key] {
            highlight(name, on: false)
        }
        activeTouches[key] = nil
        recompute()
    }

    func reset() {
        activeTouches.removeAll()
        for n in ["left", "right", "jump"] { highlight(n, on: false) }
        recompute()
    }

    // MARK: - Helpers

    private func hitButton(at scenePoint: CGPoint) -> String? {
        // Hit area = vòng tròn bán kính nới rộng cho dễ chạm trên iPad.
        for button in [leftButton, rightButton, jumpButton] {
            guard let b = button else { continue }
            let p = b.convert(scenePoint, from: scene!)
            let radius = (b == jumpButton ? 60.0 : 52.0) + 16 // pad hit area
            if hypot(p.x, p.y) <= radius { return b.name }
        }
        return nil
    }

    private func highlight(_ name: String, on: Bool) {
        let node = button(named: name)
        node?.fillColor = SKColor.white.withAlphaComponent(on ? 0.55 : buttonAlpha)
    }

    private func button(named name: String) -> SKShapeNode? {
        switch name {
        case "left":  return leftButton
        case "right": return rightButton
        case "jump":  return jumpButton
        default:      return nil
        }
    }

    private func recompute() {
        let names = Set(activeTouches.values)
        state.leftPressed = names.contains("left")
        state.rightPressed = names.contains("right")
        state.jumpHeld = names.contains("jump")
    }
}
