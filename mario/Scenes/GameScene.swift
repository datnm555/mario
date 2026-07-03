import SpriteKit

private enum GameState {
    case playing, won, lost
}

/// Scene chính: sở hữu world + player + enemies + camera. Gọi systems mỗi tick.
/// Không chứa logic chi tiết của entity — chỉ điều phối.
final class GameScene: SKScene, SKPhysicsContactDelegate {

    // Thiết kế theo độ phân giải cố định → aspectFill, độc lập thiết bị.
    static let designSize = GameConfig.designSize

    /// Màn đang chơi (router set trước khi present). Mặc định màn 1.
    var levelIndex: Int = 1
    private var levelName: String { GameConfig.levelName(for: levelIndex) }
    private let progress = ProgressStore.shared

    private let cam = SKCameraNode()
    private let touchControls = TouchControls()
    private let hud = HUDOverlay()

    private var player: Player!
    private var enemies: [any Enemy] = []
    private var level: LoadedLevel!

    private var coins = 0
    private var lives = 3
    private var gameState: GameState = .playing
    private var lastUpdate: TimeInterval = 0
    private var elapsed: TimeInterval = 0   // thời gian hoàn thành màn (best-time)

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.42, green: 0.66, blue: 0.96, alpha: 1) // bầu trời
        physicsWorld.gravity = CGVector(dx: 0, dy: -24)
        physicsWorld.contactDelegate = self
        scaleMode = .aspectFill

        camera = cam
        addChild(cam)
        cam.addChild(hud)
        cam.addChild(touchControls)
        hud.setup(designSize: GameScene.designSize)
        touchControls.setup(designSize: GameScene.designSize)

        startLevel()
    }

    private func startLevel() {
        // Dọn sạch state cũ (cho restart).
        children.filter { $0 != cam }.forEach { $0.removeFromParent() }
        enemies.removeAll()
        coins = 0
        gameState = .playing
        lastUpdate = 0
        elapsed = 0
        touchControls.reset()

        do {
            level = try LevelLoader.load(named: levelName)
        } catch {
            showMessage("Lỗi load level:\n\(error)", color: .red)
            return
        }

        addChild(level.tilesNode)
        spawnEntities()
        hud.refresh(coins: coins, lives: lives)
        centerCameraOnPlayer(immediate: true)
    }

    private func spawnEntities() {
        // Player
        let p = Player()
        p.position = level.playerSpawn
        addChild(p)
        player = p

        // Enemies (đa loại theo spawn.kind)
        for spawn in level.enemySpawns {
            let e = makeEnemy(kind: spawn.kind)
            e.node.position = spawn.position
            e.didSpawn()
            addChild(e.node)
            enemies.append(e)
        }

        // Coins
        for spawn in level.coinSpawns {
            let c = Coin()
            c.position = spawn
            addChild(c)
        }

        // Flag
        if let flagPos = level.flagPosition {
            let f = Flag()
            // Đặt chân cờ ngay trên ô spawn.
            f.position = CGPoint(x: flagPos.x, y: flagPos.y + Flag.poleSize.height / 2 - level.tileSize / 2)
            addChild(f)
        }
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing, player != nil else { return }
        let dt = lastUpdate == 0 ? 0 : currentTime - lastUpdate
        lastUpdate = currentTime
        elapsed += dt

        player.update(input: touchControls.state, dt: dt)
        for e in enemies { e.update(dt: dt) }

        checkFellOffWorld()
    }

    override func didSimulatePhysics() {
        guard gameState == .playing, let player = player else { return }
        updateGrounded(for: player)
        centerCameraOnPlayer(immediate: false)
    }

    override func didFinishUpdate() {
        hud.refresh(coins: coins, lives: lives)
    }

    /// Grounded = có ground body đang chạm và nằm phía DƯỚI player.
    private func updateGrounded(for player: Player) {
        guard let body = player.physicsBody, !player.isDead else {
            player.isOnGround = false
            return
        }
        let contacts = body.allContactedBodies()
        player.isOnGround = contacts.contains { other in
            guard other.categoryBitMask == PhysicsCategory.ground,
                  let n = other.node else { return false }
            // Phải nằm thấp hơn player rõ rệt (loại trừ va chạm tường bên hông).
            return n.position.y < player.position.y - level.tileSize * 0.25
        }
    }

    private func centerCameraOnPlayer(immediate: Bool) {
        guard let player = player else { return }
        let halfW = GameScene.designSize.width / 2
        let halfH = GameScene.designSize.height / 2
        // Clamp camera trong biên level.
        let minX = halfW
        let maxX = max(halfW, level.width - halfW)
        let targetX = min(max(player.position.x, minX), maxX)
        // Y giữ cố định hơi cao hơn giữa để thấy đất.
        let targetY = max(halfH, halfH * 0.92)

        if immediate {
            cam.position = CGPoint(x: targetX, y: targetY)
        } else {
            let lerp: CGFloat = 0.15
            cam.position.x += (targetX - cam.position.x) * lerp
            cam.position.y += (targetY - cam.position.y) * lerp
        }
    }

    private func checkFellOffWorld() {
        guard !player.isDead, player.position.y < -120 else { return }
        playerDied()
    }

    // MARK: - Physics contacts

    func didBegin(_ contact: SKPhysicsContact) {
        guard gameState == .playing else { return }
        let a = contact.bodyA
        let b = contact.bodyB
        let mask = a.categoryBitMask | b.categoryBitMask

        // Player + Coin
        if mask == (PhysicsCategory.player | PhysicsCategory.coin) {
            let coinNode = (a.categoryBitMask == PhysicsCategory.coin ? a.node : b.node) as? Coin
            if let coin = coinNode, coin.collect() {
                coins += 1
            }
            return
        }

        // Player + Flag → win
        if mask == (PhysicsCategory.player | PhysicsCategory.flag) {
            let flagNode = (a.categoryBitMask == PhysicsCategory.flag ? a.node : b.node) as? Flag
            if let flag = flagNode, !flag.reached {
                flag.reach()
                winLevel()
            }
            return
        }

        // Player + Enemy → stomp hoặc chết
        if mask == (PhysicsCategory.player | PhysicsCategory.enemy) {
            let enemyNode = (a.categoryBitMask == PhysicsCategory.enemy ? a.node : b.node) as? SKSpriteNode
            guard let node = enemyNode, let enemy = enemy(for: node),
                  !enemy.isDead, !player.isDead else { return }
            resolvePlayerEnemy(enemy)
            return
        }

        // Enemy + Enemy → mai rùa đang trượt giết con còn lại
        if mask == PhysicsCategory.enemy {
            resolveEnemyEnemy(a.node, b.node)
            return
        }

        // Player + Hazard → chết
        if mask == (PhysicsCategory.player | PhysicsCategory.hazard) {
            playerDied()
        }
    }

    private func makeEnemy(kind: EnemyKind) -> any Enemy {
        switch kind {
        case .goomba: return GoombaEnemy()
        case .koopa:  return KoopaEnemy()
        case .flying: return FlyingEnemy()
        }
    }

    private func enemy(for node: SKNode) -> (any Enemy)? {
        enemies.first { $0.node === node }
    }

    private func pruneDeadEnemies() {
        enemies.removeAll { $0.isDead }
    }

    /// Player ở trên + đang rơi → stomp; ngược lại theo phản hồi của enemy.
    private func resolvePlayerEnemy(_ enemy: any Enemy) {
        let node = enemy.node
        let playerBottom = player.position.y - Player.bodySize.height / 2
        let enemyTop = node.position.y + node.frame.height / 2
        let falling = (player.physicsBody?.velocity.dy ?? 0) <= 5

        if playerBottom >= enemyTop - 10 && falling {
            if enemy.onStompFromAbove() { player.bounce() }
        } else {
            let playerDies = enemy.onSideContact(playerX: player.position.x)
            if playerDies { playerDied() }
        }
        pruneDeadEnemies()
    }

    /// Mai trượt (isSlidingShell) tông enemy khác → giết enemy đó.
    private func resolveEnemyEnemy(_ nodeA: SKNode?, _ nodeB: SKNode?) {
        guard let nA = nodeA, let nB = nodeB,
              let eA = enemy(for: nA), let eB = enemy(for: nB) else { return }
        if eA.isSlidingShell && !eB.isDead && !eB.isSlidingShell {
            eB.onShellHit()
        } else if eB.isSlidingShell && !eA.isDead && !eA.isSlidingShell {
            eA.onShellHit()
        }
        pruneDeadEnemies()
    }

    // MARK: - Win / Lose

    private func playerDied() {
        guard gameState == .playing, !player.isDead else { return }
        player.die()
        lives -= 1
        gameState = .lost

        if lives > 0 {
            showMessage("Ối! Còn \(lives) mạng", color: .white, autoFade: true)
            run(.sequence([.wait(forDuration: 1.2), .run { [weak self] in self?.startLevel() }]))
        } else {
            // Hết mạng → chạm để về chọn màn (xử lý ở touchesBegan).
            showMessage("GAME OVER\nChạm để về chọn màn", color: SKColor(red: 1, green: 0.4, blue: 0.4, alpha: 1))
        }
    }

    private func winLevel() {
        guard gameState == .playing else { return }
        gameState = .won
        player.physicsBody?.velocity = .zero

        // Ghi tiến độ: mở màn kế, cộng coin, lưu best-time.
        progress.markCleared(level: levelIndex)
        progress.addCoins(coins)
        progress.recordTime(elapsed, level: levelIndex)

        let timeStr = String(format: "%.1fs", elapsed)
        showMessage("YOU WIN! 🎉\n⏱ \(timeStr)\nChạm để tiếp tục",
                    color: SKColor(red: 0.6, green: 1, blue: 0.6, alpha: 1))
    }

    // MARK: - Overlay

    private func showMessage(_ text: String, color: SKColor, autoFade: Bool = false) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.numberOfLines = 0
        label.text = text
        label.fontSize = 44
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        label.zPosition = 2000
        label.name = "overlayMessage"
        cam.addChild(label)
        if autoFade {
            label.run(.sequence([.wait(forDuration: 1.0), .fadeOut(withDuration: 0.2), .removeFromParent()]))
        }
    }

    private func clearOverlay() {
        cam.childNode(withName: "overlayMessage")?.removeFromParent()
    }

    // MARK: - Touch passthrough → TouchControls

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Thắng hoặc hết mạng → chạm để về màn chọn level.
        if gameState == .won || (gameState == .lost && lives <= 0) {
            SceneRouter.goLevelSelect(from: self)
            return
        }
        for t in touches {
            touchControls.touchDown(t, scenePoint: t.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchControls.touchMoved(t, scenePoint: t.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchControls.touchUp(t) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchControls.touchUp(t) }
    }
}
