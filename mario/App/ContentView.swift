import SwiftUI
import SpriteKit

/// SwiftUI wrapper host SKView qua SpriteView.
struct ContentView: View {
    private var scene: SKScene {
        let scene = MenuScene(size: GameConfig.designSize)
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
