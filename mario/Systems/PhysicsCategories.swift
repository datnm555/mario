import Foundation

/// Bitmask categories cho physics contact/collision.
/// Mỗi loại object 1 bit để filter va chạm rõ ràng.
enum PhysicsCategory {
    static let none:   UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let enemy:  UInt32 = 1 << 1
    static let ground: UInt32 = 1 << 2
    static let coin:   UInt32 = 1 << 3
    static let flag:    UInt32 = 1 << 4
    static let hazard:  UInt32 = 1 << 5
    static let powerup: UInt32 = 1 << 6
    static let projectile: UInt32 = 1 << 7
    static let all:    UInt32 = .max
}
