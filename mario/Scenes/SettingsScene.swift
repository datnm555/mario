import SpriteKit

/// Màn cài đặt: mỗi hàng là 1 nút bấm để đổi giá trị (toggle/cycle).
/// Đọc/ghi SettingsStore, áp side-effect ngay (audio volume, control size...).
final class SettingsScene: SKScene {

    private let settings = SettingsStore.shared
    private var rows: [String: ButtonNode] = [:]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.28, green: 0.34, blue: 0.52, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "CÀI ĐẶT"
        title.fontSize = 46
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 210)
        addChild(title)

        let items = ["audio", "bgm", "sfx", "control", "hand", "haptic"]
        let rowH: CGFloat = 58
        let startY: CGFloat = 130
        for (i, id) in items.enumerated() {
            let button = ButtonNode(id: id, text: rowText(id), size: CGSize(width: 460, height: 48))
            button.position = CGPoint(x: 0, y: startY - CGFloat(i) * rowH)
            addChild(button)
            rows[id] = button
        }

        let back = ButtonNode(id: "back", text: "‹ Xong", size: CGSize(width: 160, height: 50),
                              fill: SKColor(red: 0.30, green: 0.30, blue: 0.36, alpha: 1))
        back.position = CGPoint(x: 0, y: startY - CGFloat(items.count) * rowH - 10)
        addChild(back)
    }

    private func rowText(_ id: String) -> String {
        switch id {
        case "audio":   return "Âm thanh:  \(settings.audioEnabled ? "Bật" : "Tắt")"
        case "bgm":     return "Nhạc nền:  \(settings.bgmVolume.label)"
        case "sfx":     return "Hiệu ứng:  \(settings.sfxVolume.label)"
        case "control": return "Cỡ nút:  \(settings.controlScale.label)"
        case "hand":    return "Tay thuận:  \(settings.leftHanded ? "Trái" : "Phải")"
        case "haptic":  return "Rung:  \(settings.hapticEnabled ? "Bật" : "Tắt")"
        default:        return ""
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first,
              let button = tappedButton(at: t.location(in: self)) else { return }
        button.flash()
        HapticManager.shared.play(.selection)

        switch button.id {
        case "audio":   settings.audioEnabled.toggle(); AudioManager.shared.refreshVolume()
        case "bgm":     settings.bgmVolume = settings.bgmVolume.next; AudioManager.shared.refreshVolume()
        case "sfx":     settings.sfxVolume = settings.sfxVolume.next
        case "control": settings.controlScale = settings.controlScale.next
        case "hand":    settings.leftHanded.toggle()
        case "haptic":  settings.hapticEnabled.toggle()
        case "back":    SceneRouter.goMenu(from: self); return
        default:        break
        }
        rows[button.id]?.setText(rowText(button.id))
    }
}
