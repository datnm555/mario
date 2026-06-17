import SpriteKit

/// Kết quả load 1 level: world node chứa tile, + các spawn point cho entity.
struct LoadedLevel {
    let tilesNode: SKNode
    let playerSpawn: CGPoint
    let enemySpawns: [CGPoint]
    let coinSpawns: [CGPoint]
    let flagPosition: CGPoint?
    let width: CGFloat
    let height: CGFloat
    let tileSize: CGFloat
}

/// Schema JSON cho 1 level (ASCII grid, dễ edit bằng tay).
private struct LevelData: Decodable {
    let name: String
    let tileSize: CGFloat
    /// Các hàng từ TRÊN xuống DƯỚI. Mỗi ký tự = 1 ô.
    /// 'G'/'#' = solid ground, '.' = trống, 'P' = player spawn,
    /// 'E' = enemy, 'C' = coin, 'F' = flag (chân cờ).
    let rows: [String]
}

enum LevelLoaderError: Error {
    case fileNotFound(String)
    case decodeFailed(String)
}

/// Data-driven loader: tên level → (tilemap node + spawn points).
/// Không đụng tới gameplay → swap level/format dễ dàng.
enum LevelLoader {

    static func load(named name: String) throws -> LoadedLevel {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw LevelLoaderError.fileNotFound(name)
        }
        let raw = try Data(contentsOf: url)
        return try load(jsonData: raw)
    }

    /// Parse trực tiếp từ JSON Data — tách khỏi bundle để test được.
    static func load(jsonData: Data) throws -> LoadedLevel {
        let data: LevelData
        do {
            data = try JSONDecoder().decode(LevelData.self, from: jsonData)
        } catch {
            throw LevelLoaderError.decodeFailed("\(error)")
        }
        return build(from: data)
    }

    private static func build(from data: LevelData) -> LoadedLevel {
        let ts = data.tileSize
        let rowCount = data.rows.count
        let colCount = data.rows.map { $0.count }.max() ?? 0

        let tilesNode = SKNode()
        var playerSpawn = CGPoint(x: ts, y: ts * 2)
        var enemySpawns: [CGPoint] = []
        var coinSpawns: [CGPoint] = []
        var flagPosition: CGPoint?

        // Quy đổi (row, col) → world position (SpriteKit y hướng lên).
        // row 0 ở trên cùng → y lớn nhất.
        func worldPos(row: Int, col: Int) -> CGPoint {
            let x = CGFloat(col) * ts + ts / 2
            let y = CGFloat(rowCount - 1 - row) * ts + ts / 2
            return CGPoint(x: x, y: y)
        }

        for (row, line) in data.rows.enumerated() {
            for (col, ch) in line.enumerated() {
                let pos = worldPos(row: row, col: col)
                switch ch {
                case "G", "#":
                    tilesNode.addChild(makeSolidTile(at: pos, size: ts, brick: ch == "#"))
                case "P":
                    playerSpawn = pos
                case "E":
                    enemySpawns.append(pos)
                case "C":
                    coinSpawns.append(pos)
                case "F":
                    flagPosition = pos
                default:
                    break // '.' hoặc khoảng trắng
                }
            }
        }

        return LoadedLevel(
            tilesNode: tilesNode,
            playerSpawn: playerSpawn,
            enemySpawns: enemySpawns,
            coinSpawns: coinSpawns,
            flagPosition: flagPosition,
            width: CGFloat(colCount) * ts,
            height: CGFloat(rowCount) * ts,
            tileSize: ts
        )
    }

    /// Placeholder rectangle cho solid tile (xám = đất, cam = brick).
    private static func makeSolidTile(at pos: CGPoint, size: CGFloat, brick: Bool) -> SKSpriteNode {
        let color = brick ? SKColor(red: 0.78, green: 0.42, blue: 0.20, alpha: 1)
                          : SKColor(red: 0.36, green: 0.30, blue: 0.26, alpha: 1)
        let node = SKSpriteNode(color: color, size: CGSize(width: size, height: size))
        node.position = pos
        node.name = "ground"
        let body = SKPhysicsBody(rectangleOf: node.size)
        body.isDynamic = false
        body.friction = 0.2
        body.restitution = 0
        body.categoryBitMask = PhysicsCategory.ground
        body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.player
        node.physicsBody = body
        return node
    }
}
