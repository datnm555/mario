import XCTest
import SpriteKit
@testable import mario

final class QuestionBlockTests: XCTestCase {

    func testStartsUnused() {
        let b = QuestionBlock(content: .coin)
        XCTAssertFalse(b.isUsed)
        XCTAssertEqual(b.content, .coin)
        XCTAssertNotNil(b.physicsBody)
        XCTAssertEqual(b.physicsBody?.categoryBitMask, PhysicsCategory.block)
    }

    func testBumpReturnsContentOnce() {
        let b = QuestionBlock(content: .mushroom)
        let first = b.bump()
        XCTAssertEqual(first, .mushroom)
        XCTAssertTrue(b.isUsed)
    }

    func testBumpTwiceGivesNothingSecondTime() {
        let b = QuestionBlock(content: .coin)
        XCTAssertEqual(b.bump(), .coin)
        XCTAssertNil(b.bump(), "Block đã dùng → không nhả nữa")
    }

    func testStaysSolidAfterUse() {
        let b = QuestionBlock(content: .coin)
        _ = b.bump()
        // Vẫn còn physicsBody (đứng lên được) sau khi thành block rỗng.
        XCTAssertNotNil(b.physicsBody)
        XCTAssertEqual(b.physicsBody?.categoryBitMask, PhysicsCategory.block)
    }
}
