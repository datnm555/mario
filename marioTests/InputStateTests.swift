import XCTest
@testable import mario

final class InputStateTests: XCTestCase {

    func testDefaultIsNeutral() {
        let s = InputState()
        XCTAssertEqual(s.horizontal, 0)
        XCTAssertFalse(s.jumpHeld)
    }

    func testRightOnly() {
        var s = InputState()
        s.rightPressed = true
        XCTAssertEqual(s.horizontal, 1)
    }

    func testLeftOnly() {
        var s = InputState()
        s.leftPressed = true
        XCTAssertEqual(s.horizontal, -1)
    }

    func testBothPressedCancelsOut() {
        var s = InputState()
        s.leftPressed = true
        s.rightPressed = true
        XCTAssertEqual(s.horizontal, 0, "Giữ cả 2 nút → đứng yên")
    }

    func testEquatable() {
        var a = InputState()
        var b = InputState()
        XCTAssertEqual(a, b)
        a.jumpHeld = true
        XCTAssertNotEqual(a, b)
        b.jumpHeld = true
        XCTAssertEqual(a, b)
    }
}
