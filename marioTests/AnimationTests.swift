import XCTest
import SpriteKit
@testable import mario

final class AnimationTests: XCTestCase {

    func testMovementStatesHaveAnimation() {
        XCTAssertNotNil(AnimationLibrary.loopingAction(for: .idle))
        XCTAssertNotNil(AnimationLibrary.loopingAction(for: .running))
        XCTAssertNotNil(AnimationLibrary.loopingAction(for: .jumping))
        XCTAssertNotNil(AnimationLibrary.loopingAction(for: .falling))
    }

    func testDeadHasNoLoopingAnimation() {
        XCTAssertNil(AnimationLibrary.loopingAction(for: .dead))
    }

    func testHelperActionsExist() {
        XCTAssertGreaterThan(AnimationLibrary.hurtBlink(duration: 1.0).duration, 0)
        _ = AnimationLibrary.resetScale
        _ = AnimationLibrary.victory
    }
}

final class ParallaxBackgroundTests: XCTestCase {

    func testSetupAddsLayers() {
        let bg = ParallaxBackground()
        bg.setup(designSize: CGSize(width: 1024, height: 576))
        XCTAssertGreaterThan(bg.children.count, 0, "Có ít nhất 1 lớp nền")
    }

    func testUpdateShiftsLayers() {
        let bg = ParallaxBackground()
        bg.setup(designSize: CGSize(width: 1024, height: 576))
        let before = bg.children.first!.position.x
        bg.update(cameraX: 500)
        let after = bg.children.first!.position.x
        XCTAssertNotEqual(before, after, "Cuộn camera → lớp nền dịch chuyển")
    }

    func testUpdateIsSeamlessWithinSpacing() {
        let bg = ParallaxBackground()
        bg.setup(designSize: CGSize(width: 1024, height: 576))
        bg.update(cameraX: 100000)   // offset lớn không văng ra vô cực (dùng modulo)
        let x = bg.children.first!.position.x
        XCTAssertLessThan(abs(x), 1000, "Vị trí lớp wrap trong biên spacing")
    }
}
