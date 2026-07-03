import SwiftUI
import SpriteKit

/// SwiftUI wrapper host SKView qua SpriteView.
struct ContentView: View {
    private var scene: SKScene {
        // Dev/test affordance: `--args -startLevel N` vào thẳng màn N để chụp/kiểm thử.
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "-startLevel"),
           idx + 1 < args.count, let n = Int(args[idx + 1]) {
            return SceneRouter.makeGame(levelIndex: n)
        }
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
