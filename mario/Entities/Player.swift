import SpriteKit

enum PlayerState {
    case idle, running, jumping, falling, dead
}

/// Cấp sức mạnh: small (cơ bản) → big (chịu 1 đòn) → fire (bắn được).
enum PowerState {
    case small, big, fire
}

/// Player: placeholder rectangle đỏ + physicsBody + state machine.
/// Đọc InputState → áp velocity. Animation/màu theo state.
final class Player: SKSpriteNode {

    // Tuning (velocity-based → deterministic, không phụ thuộc mass)
    private let moveSpeed: CGFloat = 240
    private let jumpVelocity: CGFloat = 760
    private let maxFallSpeed: CGFloat = -1100
    /// Hệ số cắt độ cao nhảy khi thả nút sớm (variable jump height).
    private let jumpCutFactor: CGFloat = 0.45
    /// Cho phép nhảy trong khoảng này sau khi rời mép (coyote time).
    private let coyoteTime: TimeInterval = 0.10
    /// Bấm nhảy sớm trước khi chạm đất vẫn được ghi nhận (jump buffering).
    private let jumpBufferTime: TimeInterval = 0.12

    private let invulnDuration: TimeInterval = 1.2
    private let shootCooldownDuration: TimeInterval = 0.4

    private(set) var state: PlayerState = .idle
    private(set) var power: PowerState = .small
    var isOnGround = false
    private var wasJumpHeld = false
    private(set) var isDead = false
    private var coyoteTimer: TimeInterval = 0
    private var jumpBufferTimer: TimeInterval = 0

    /// Hướng nhìn gần nhất (+1 phải, -1 trái) — dùng để bắn fireball.
    private(set) var facing: CGFloat = 1
    private var invulnTimer: TimeInterval = 0
    private var shootTimer: TimeInterval = 0
    var isInvulnerable: Bool { invulnTimer > 0 }
    var canShoot: Bool { power == .fire }

    static let bodySize = CGSize(width: 28, height: 30)

    init() {
        super.init(texture: nil, color: SKColor(red: 0.86, green: 0.20, blue: 0.18, alpha: 1),
                   size: Player.bodySize)
        name = "player"
        zPosition = 10
        setupPhysics()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.allowsRotation = false
        body.restitution = 0
        body.friction = 0.0
        body.linearDamping = 0
        body.mass = 0.2
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground
        body.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.coin |
                                  PhysicsCategory.flag | PhysicsCategory.hazard |
                                  PhysicsCategory.powerup | PhysicsCategory.ground
        physicsBody = body
    }

    /// Gọi mỗi frame từ GameScene.update.
    func update(input: InputState, dt: TimeInterval) {
        guard !isDead, let body = physicsBody else { return }

        // Di chuyển ngang: set velocity.x trực tiếp (control chặt như platformer cổ điển).
        body.velocity.dx = input.horizontal * moveSpeed
        if input.horizontal != 0 { facing = input.horizontal > 0 ? 1 : -1 }

        // Đếm ngược các timer.
        if invulnTimer > 0 { invulnTimer = max(0, invulnTimer - dt) }
        if shootTimer > 0 { shootTimer = max(0, shootTimer - dt) }

        // Đếm ngược coyote time: nạp đầy khi đứng đất, cạn dần khi trên không.
        if isOnGround {
            coyoteTimer = coyoteTime
        } else {
            coyoteTimer = max(0, coyoteTimer - dt)
        }

        // Jump buffer: nạp khi có cạnh lên của nút jump, cạn dần theo thời gian.
        let jumpEdge = input.jumpHeld && !wasJumpHeld
        if jumpEdge {
            jumpBufferTimer = jumpBufferTime
        } else {
            jumpBufferTimer = max(0, jumpBufferTimer - dt)
        }

        // Nhảy khi: có buffer chờ + còn coyote credit.
        if jumpBufferTimer > 0 && coyoteTimer > 0 {
            body.velocity.dy = jumpVelocity
            isOnGround = false
            coyoteTimer = 0
            jumpBufferTimer = 0
        }

        // Variable jump height: thả nút khi đang lên → cắt bớt lực nhảy.
        let jumpReleased = !input.jumpHeld && wasJumpHeld
        if jumpReleased && body.velocity.dy > 0 {
            body.velocity.dy *= jumpCutFactor
        }
        wasJumpHeld = input.jumpHeld

        // Giới hạn tốc độ rơi.
        if body.velocity.dy < maxFallSpeed {
            body.velocity.dy = maxFallSpeed
        }

        updateState(velocity: body.velocity)
    }

    private func updateState(velocity: CGVector) {
        let newState: PlayerState
        if !isOnGround {
            newState = velocity.dy > 1 ? .jumping : .falling
        } else if abs(velocity.dx) > 1 {
            newState = .running
        } else {
            newState = .idle
        }
        guard newState != state else { return }
        state = newState
        applyStateAppearance()
    }

    private func applyStateAppearance() {
        // Placeholder: màu theo cấp sức mạnh (dead ưu tiên). Thay = animation thật sau.
        if state == .dead {
            color = SKColor(red: 0.35, green: 0.35, blue: 0.40, alpha: 1)
        } else {
            applyPowerAppearance()
        }
    }

    private func applyPowerAppearance() {
        guard !isDead else { return }
        switch power {
        case .small: color = SKColor(red: 0.86, green: 0.20, blue: 0.18, alpha: 1) // đỏ
        case .big:   color = SKColor(red: 0.20, green: 0.70, blue: 0.55, alpha: 1) // xanh ngọc
        case .fire:  color = SKColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1) // trắng
        }
    }

    // MARK: - Power-ups

    /// Nấm: small → big. Đã big/fire thì giữ nguyên (chỉ tính điểm sau).
    func grow() {
        guard !isDead else { return }
        if power == .small {
            power = .big
            applyPowerAppearance()
        }
    }

    /// Hoa lửa: lên thẳng fire.
    func becomeFire() {
        guard !isDead else { return }
        power = .fire
        applyPowerAppearance()
    }

    /// Trúng đòn. Trả về true nếu CHÍ MẠNG (small → chết); false nếu chỉ xuống cấp.
    /// Đang bất tử (vừa trúng đòn) → bỏ qua.
    func takeDamage() -> Bool {
        guard !isDead, !isInvulnerable else { return false }
        switch power {
        case .fire:
            power = .big; startInvulnerability(); return false
        case .big:
            power = .small; startInvulnerability(); return false
        case .small:
            return true
        }
    }

    private func startInvulnerability() {
        invulnTimer = invulnDuration
        applyPowerAppearance()
        removeAction(forKey: "invuln")
        let blink = SKAction.sequence([.fadeAlpha(to: 0.35, duration: 0.1),
                                       .fadeAlpha(to: 1.0, duration: 0.1)])
        run(.sequence([.repeat(blink, count: Int(invulnDuration / 0.2)),
                       .fadeAlpha(to: 1.0, duration: 0)]), withKey: "invuln")
    }

    /// Thử bắn: chỉ khi đang fire + hết cooldown. Trả về true nếu được bắn.
    func tryShoot() -> Bool {
        guard !isDead, power == .fire, shootTimer <= 0 else { return false }
        shootTimer = shootCooldownDuration
        return true
    }

    /// Bật nhẹ lên sau khi stomp enemy.
    func bounce() {
        physicsBody?.velocity.dy = jumpVelocity * 0.7
        isOnGround = false
    }

    func die() {
        guard !isDead else { return }
        isDead = true
        state = .dead
        applyStateAppearance()
        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.none
        // Văng lên rồi rơi xuống (death animation cổ điển).
        physicsBody?.velocity = CGVector(dx: 0, dy: jumpVelocity * 0.8)
    }
}
