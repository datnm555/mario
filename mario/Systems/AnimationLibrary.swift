import SpriteKit

/// Thư viện animation placeholder theo state (dùng SKAction scale/nhịp).
/// Khung sẵn để sau thay bằng sprite-sheet thật mà không đụng Player logic.
enum AnimationLibrary {

    /// Action lặp cho từng trạng thái di chuyển. nil = không animation riêng.
    static func loopingAction(for state: PlayerState) -> SKAction? {
        switch state {
        case .idle:
            // Thở nhẹ.
            let up = SKAction.scaleY(to: 1.04, duration: 0.6)
            up.timingMode = .easeInEaseOut
            return .repeatForever(.sequence([up, up.reversed()]))
        case .running:
            // Nhún nhảy nhanh.
            let squash = SKAction.group([.scaleX(to: 1.08, duration: 0.1), .scaleY(to: 0.92, duration: 0.1)])
            let stretch = SKAction.group([.scaleX(to: 0.96, duration: 0.1), .scaleY(to: 1.04, duration: 0.1)])
            return .repeatForever(.sequence([squash, stretch]))
        case .jumping:
            // Vươn dài lên.
            return .group([.scaleX(to: 0.9, duration: 0.12), .scaleY(to: 1.15, duration: 0.12)])
        case .falling:
            // Hơi dẹt.
            return .group([.scaleX(to: 1.1, duration: 0.12), .scaleY(to: 0.92, duration: 0.12)])
        case .dead:
            return nil
        }
    }

    /// Reset về tỉ lệ gốc.
    static var resetScale: SKAction {
        .group([.scaleX(to: 1, duration: 0.1), .scaleY(to: 1, duration: 0.1)])
    }

    /// Nhấp nháy khi trúng đòn.
    static func hurtBlink(duration: TimeInterval) -> SKAction {
        let blink = SKAction.sequence([.fadeAlpha(to: 0.35, duration: 0.1),
                                       .fadeAlpha(to: 1.0, duration: 0.1)])
        return .sequence([.repeat(blink, count: max(1, Int(duration / 0.2))),
                          .fadeAlpha(to: 1.0, duration: 0)])
    }

    /// Ăn mừng thắng màn: nhảy tưng + xoay nhẹ.
    static var victory: SKAction {
        let hop = SKAction.sequence([.moveBy(x: 0, y: 20, duration: 0.15),
                                     .moveBy(x: 0, y: -20, duration: 0.15)])
        let wobble = SKAction.sequence([.rotate(toAngle: 0.15, duration: 0.15),
                                        .rotate(toAngle: -0.15, duration: 0.15)])
        return .repeat(.group([hop, wobble]), count: 3)
    }
}
