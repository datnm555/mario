import SpriteKit

/// Điều hướng giữa các scene (menu ↔ level select ↔ game) với transition.
/// Scene gọi các hàm `go...(from:)` truyền chính nó vào.
enum SceneRouter {

    private static func configure<T: SKScene>(_ scene: T) -> T {
        scene.scaleMode = .aspectFill
        return scene
    }

    static func makeMenu() -> MenuScene {
        configure(MenuScene(size: GameConfig.designSize))
    }

    static func makeLevelSelect() -> LevelSelectScene {
        configure(LevelSelectScene(size: GameConfig.designSize))
    }

    static func makeGame(levelIndex: Int) -> GameScene {
        let scene = GameScene(size: GameConfig.designSize)
        scene.levelIndex = levelIndex
        return configure(scene)
    }

    // MARK: - Transitions

    static func goMenu(from scene: SKScene) {
        scene.view?.presentScene(makeMenu(), transition: .fade(withDuration: 0.4))
    }

    static func goLevelSelect(from scene: SKScene) {
        scene.view?.presentScene(makeLevelSelect(), transition: .fade(withDuration: 0.4))
    }

    static func goGame(levelIndex: Int, from scene: SKScene) {
        scene.view?.presentScene(makeGame(levelIndex: levelIndex),
                                 transition: .doorway(withDuration: 0.5))
    }
}
