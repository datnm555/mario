import SpriteKit
import UIKit

/// Nền cuộn nhiều lớp (parallax). Là child của camera → luôn phủ màn hình;
/// cuộn nội dung theo cameraX với hệ số khác nhau tạo chiều sâu.
/// Các phần tử lặp đều theo `spacing` nên wrap theo modulo là liền mạch.
final class ParallaxBackground: SKNode {

    private struct Layer {
        let node: SKNode
        let factor: CGFloat   // 0 = đứng yên (xa), 1 = theo sát camera (gần)
        let spacing: CGFloat
    }

    private var layers: [Layer] = []

    func setup(designSize: CGSize) {
        removeAllChildren()
        layers.removeAll()
        let halfW = designSize.width / 2
        let halfH = designSize.height / 2

        // Lớp mây (xa, chậm).
        let clouds = SKNode()
        clouds.zPosition = -100
        let cloudSpacing: CGFloat = 340
        buildRepeating(in: clouds, spacing: cloudSpacing, halfW: halfW) { x in
            let cloud = SKNode()
            for (dx, dy, r) in [(-24.0, 0.0, 20.0), (0.0, 6.0, 26.0), (26.0, 0.0, 18.0)] {
                let puff = SKShapeNode(circleOfRadius: r)
                puff.fillColor = SKColor.white.withAlphaComponent(0.85)
                puff.strokeColor = .clear
                puff.position = CGPoint(x: dx, y: dy)
                cloud.addChild(puff)
            }
            cloud.position = CGPoint(x: x, y: halfH * 0.55)
            return cloud
        }
        addChild(clouds)
        layers.append(Layer(node: clouds, factor: 0.15, spacing: cloudSpacing))

        // Lớp đồi (gần hơn, nhanh hơn).
        let hills = SKNode()
        hills.zPosition = -90
        let hillSpacing: CGFloat = 260
        buildRepeating(in: hills, spacing: hillSpacing, halfW: halfW) { x in
            let hill = SKShapeNode(ellipseOf: CGSize(width: 300, height: 200))
            hill.fillColor = SKColor(red: 0.30, green: 0.62, blue: 0.36, alpha: 1)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: x, y: -halfH + 40)
            return hill
        }
        addChild(hills)
        layers.append(Layer(node: hills, factor: 0.35, spacing: hillSpacing))
    }

    /// Sinh phần tử lặp phủ đủ bề rộng (thêm biên để wrap không hụt).
    private func buildRepeating(in parent: SKNode, spacing: CGFloat, halfW: CGFloat,
                                make: (CGFloat) -> SKNode) {
        let count = Int(ceil(halfW * 2 / spacing)) + 4
        let start = -count / 2
        for k in start...(start + count) {
            parent.addChild(make(CGFloat(k) * spacing))
        }
    }

    /// Gọi mỗi frame với vị trí camera để cuộn.
    func update(cameraX: CGFloat) {
        // Reduce Motion: giữ nền tĩnh cho người nhạy cảm chuyển động.
        if UIAccessibility.isReduceMotionEnabled { return }
        for layer in layers {
            let offset = (cameraX * layer.factor).truncatingRemainder(dividingBy: layer.spacing)
            layer.node.position.x = -offset
        }
    }
}
