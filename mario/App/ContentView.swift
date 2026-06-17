import SwiftUI
import SpriteKit

/// SwiftUI wrapper host SKView qua SpriteView.
struct ContentView: View {
    private var scene: GameScene {
        let scene = GameScene(size: GameScene.designSize)
        scene.scaleMode = .aspectFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene,
                   options: [.ignoresSiblingOrder])
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
