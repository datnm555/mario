import SpriteKit

/// Lưới chọn màn: nút cho từng level, khoá màn chưa mở (🔒).
final class LevelSelectScene: SKScene {

    private let progress = ProgressStore.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.32, green: 0.52, blue: 0.86, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "CHỌN MÀN"
        title.fontSize = 46
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 190)
        addChild(title)

        layoutLevelButtons()

        let back = ButtonNode(id: "back", text: "‹ Menu", size: CGSize(width: 150, height: 50),
                              fill: SKColor(red: 0.30, green: 0.30, blue: 0.36, alpha: 1))
        back.position = CGPoint(x: -GameConfig.designSize.width / 2 + 100,
                                y: GameConfig.designSize.height / 2 - 50)
        addChild(back)
    }

    private func layoutLevelButtons() {
        let perRow = 5
        let cell = CGSize(width: 130, height: 110)
        let gap: CGFloat = 22
        let total = GameConfig.totalLevels
        let rowWidth = CGFloat(min(perRow, total)) * cell.width + CGFloat(min(perRow, total) - 1) * gap
        let startX = -rowWidth / 2 + cell.width / 2

        for i in 0..<total {
            let level = i + 1
            let col = i % perRow
            let row = i / perRow
            let unlocked = progress.isUnlocked(level: level)
            let text = unlocked ? "\(level)" : "🔒"
            let fill: SKColor = unlocked
                ? SKColor(red: 0.20, green: 0.55, blue: 0.35, alpha: 1)
                : SKColor(red: 0.35, green: 0.35, blue: 0.40, alpha: 1)
            let button = ButtonNode(id: "level-\(level)", text: text, size: cell, fill: fill)
            button.position = CGPoint(x: startX + CGFloat(col) * (cell.width + gap),
                                      y: 60 - CGFloat(row) * (cell.height + gap))
            button.setEnabled(unlocked)
            addChild(button)

            if unlocked, let best = progress.bestTime(level: level) {
                let time = SKLabelNode(fontNamed: "AvenirNext-Medium")
                time.text = String(format: "⏱ %.1fs", best)
                time.fontSize = 15
                time.fontColor = SKColor.white.withAlphaComponent(0.9)
                time.verticalAlignmentMode = .center
                time.position = CGPoint(x: button.position.x, y: button.position.y - cell.height / 2 - 14)
                addChild(time)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first,
              let button = tappedButton(at: t.location(in: self)) else { return }
        button.flash()
        if button.id == "back" {
            SceneRouter.goMenu(from: self)
        } else if button.id.hasPrefix("level-"),
                  let level = Int(button.id.dropFirst("level-".count)) {
            SceneRouter.goGame(levelIndex: level, from: self)
        }
    }
}
