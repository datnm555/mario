import XCTest
import CoreGraphics
@testable import mario

final class LevelLoaderTests: XCTestCase {

    /// Grid 3×3 đã biết trước để verify quy đổi toạ độ + đếm spawn.
    ///   row0: P . C
    ///   row1: E . F
    ///   row2: G G G
    /// tileSize = 10 → world y hướng lên, row0 ở trên cùng.
    private func sampleData() -> Data {
        let json = """
        { "name": "t", "tileSize": 10, "rows": ["P.C", "E.F", "GGG"] }
        """
        return Data(json.utf8)
    }

    func testDimensions() throws {
        let lvl = try LevelLoader.load(jsonData: sampleData())
        XCTAssertEqual(lvl.tileSize, 10)
        XCTAssertEqual(lvl.width, 30)
        XCTAssertEqual(lvl.height, 30)
    }

    func testPlayerSpawnPosition() throws {
        let lvl = try LevelLoader.load(jsonData: sampleData())
        // row0,col0 → x = 0*10+5 = 5 ; y = (3-1-0)*10+5 = 25
        XCTAssertEqual(lvl.playerSpawn, CGPoint(x: 5, y: 25))
    }

    func testEnemyAndCoinSpawns() throws {
        let lvl = try LevelLoader.load(jsonData: sampleData())
        XCTAssertEqual(lvl.enemySpawns.count, 1)
        XCTAssertEqual(lvl.coinSpawns.count, 1)
        // enemy row1,col0 → (5, 15) ; coin row0,col2 → (25, 25)
        XCTAssertEqual(lvl.enemySpawns.first, CGPoint(x: 5, y: 15))
        XCTAssertEqual(lvl.coinSpawns.first, CGPoint(x: 25, y: 25))
    }

    func testFlagPosition() throws {
        let lvl = try LevelLoader.load(jsonData: sampleData())
        // flag row1,col2 → (25, 15)
        XCTAssertEqual(lvl.flagPosition, CGPoint(x: 25, y: 15))
    }

    func testSolidTilesGenerated() throws {
        let lvl = try LevelLoader.load(jsonData: sampleData())
        // 3 ô ground ở row2 → 3 node solid, mỗi node có physicsBody static.
        XCTAssertEqual(lvl.tilesNode.children.count, 3)
        for tile in lvl.tilesNode.children {
            XCTAssertNotNil(tile.physicsBody)
            XCTAssertEqual(tile.physicsBody?.isDynamic, false)
            XCTAssertEqual(tile.physicsBody?.categoryBitMask, PhysicsCategory.ground)
        }
    }

    func testBrickTileGenerated() throws {
        let data = Data("{ \"name\": \"b\", \"tileSize\": 8, \"rows\": [\"#\"] }".utf8)
        let lvl = try LevelLoader.load(jsonData: data)
        XCTAssertEqual(lvl.tilesNode.children.count, 1)
        XCTAssertEqual(lvl.tilesNode.children.first?.physicsBody?.categoryBitMask, PhysicsCategory.ground)
    }

    func testNoFlagWhenAbsent() throws {
        let data = Data(#"{ "name": "n", "tileSize": 10, "rows": ["P..", "GGG"] }"#.utf8)
        let lvl = try LevelLoader.load(jsonData: data)
        XCTAssertNil(lvl.flagPosition)
    }

    func testInvalidJSONThrows() {
        let bad = Data("{ not valid json".utf8)
        XCTAssertThrowsError(try LevelLoader.load(jsonData: bad)) { error in
            guard case LevelLoaderError.decodeFailed = error else {
                return XCTFail("Mong đợi decodeFailed, nhận \(error)")
            }
        }
    }
}
