# Mario 2D trên iOS/iPad — Design Spec

**Ngày:** 2026-06-17
**Trạng thái:** Draft (chưa duyệt chi tiết — cần chốt lại các "Open Questions" trước khi viết implementation plan)
**Mục tiêu cuối:** Game platformer 2D phong cách Mario, chạy iPhone + iPad, build bằng Xcode, đường dài là submit App Store.

---

## 1. Bối cảnh & ràng buộc

### 1.1 Tech stack đã chốt
- **Ngôn ngữ:** Swift (hiện đại, không Objective-C)
- **Game engine:** SpriteKit (Apple's 2D engine — physics + sprite + animation + tilemap có sẵn)
- **IDE/Build:** Xcode (yêu cầu macOS — đã có vì user đang trên Darwin)
- **Target:** iOS 17+ (đa số iPhone/iPad đời mới), orientation **landscape** (game platformer dọc ngang)
- **Min device:** iPhone (mọi size), iPad (cả size), Apple Pencil không cần

### 1.2 Ràng buộc pháp lý — QUAN TRỌNG
- "Mario", Goomba, Koopa, Bowser, Princess Peach, ống xanh, cờ kết thúc level... đều là **IP của Nintendo**.
- **KHÔNG submit lên App Store được** nếu dùng art/tên/nhân vật của Mario — Apple reject hoặc Nintendo strike.
- Hai con đường:
  - **(A) Học tập nội bộ** — clone Mario, build chạy thử trên thiết bị của mình, KHÔNG release.
  - **(B) Original game** — giữ gameplay platformer "Mario-like" nhưng đổi nhân vật/world/tên thành tài sản gốc → mới submit được.
- Spec này thiết kế **architecture sao cho swap art/asset dễ dàng** (data-driven), nên có thể start với art Mario placeholder cho sprint đầu, rồi thay original art sau khi muốn submit.

---

## 2. Phân rã dự án (Roadmap theo sprint)

Một dự án này quá lớn cho 1 spec — chia thành các sprint, **mỗi sprint là 1 sub-project độc lập** có spec + plan + implementation riêng. Sau khi finish sprint N mới mở sprint N+1.

### Sprint 1 — MVP Vertical Slice (FOCUS ĐẦU TIÊN)
Mục tiêu: chạy được trên iPad/iPhone, **1 màn chơi playable**.
- Xcode project SpriteKit scaffold (landscape, multi-orientation)
- Player: chạy trái/phải, nhảy, gravity, collision với ground
- Tile-based level từ 1 file (tmx hoặc JSON đơn giản)
- Camera follow player
- 1 enemy (đi đi lại lại, stomp để giết, chạm hông thì player chết)
- HUD tối thiểu: số coin nhặt được, life count
- 1 power-up: coin (ăn được → +1)
- Touch controls overlay: D-pad trái/phải + nút Jump (responsive iPhone & iPad)
- Game over → restart màn
- Goal: chạm cờ cuối màn → "You win" overlay → restart

**Tiêu chí done:** Build & run trên simulator + 1 device thật, chơi xong 1 màn không crash.

### Sprint 2 — Content & polish
- 3–5 màn (world map đơn giản, level select)
- Thêm 2 enemy nữa (turtle/koopa-like, flying)
- Power-up: mushroom (lớn lên), fire flower (bắn)
- Hidden block, ống xanh (transport)
- Animation polish (idle, run, jump, fall, hurt, victory)
- Background parallax
- Audio: BGM mỗi world + SFX (jump, coin, stomp, power-up, death)
- Save progress (UserDefaults: max level cleared)

### Sprint 3 — Menu, settings, accessibility
- Title screen, pause menu, settings (audio volume, control layout)
- Haptic feedback
- Game Center leaderboard (best time/score per level) — optional
- Accessibility: VoiceOver cho menu, control size scale

### Sprint 4 — Original IP & submit App Store
- Thay toàn bộ art + tên thành tài sản gốc (concept thiết kế trước)
- App icon, screenshots, marketing text
- Apple Developer Program ($99/năm)
- App Store Connect: metadata, age rating, privacy policy
- TestFlight beta
- Submit & respond review feedback
- Launch

---

## 3. Architecture cho Sprint 1 (chi tiết)

### 3.1 Cấu trúc Xcode project
```
mario.xcodeproj
mario/
├── App/
│   ├── MarioApp.swift          # @main, SwiftUI shell hosting SpriteView
│   ├── ContentView.swift       # SwiftUI wrapper cho SKView
│   └── Info.plist              # landscape only, supports iPad+iPhone
├── Scenes/
│   ├── GameScene.swift         # SKScene chính: world, player, enemies, camera
│   ├── HUDOverlay.swift        # SKNode cho coin count + life
│   └── TouchControls.swift     # SKNode: D-pad + jump button
├── Entities/
│   ├── Player.swift            # SKSpriteNode + physicsBody + state machine
│   ├── Enemy.swift             # base class + GoombaEnemy subclass
│   ├── Coin.swift              # SKSpriteNode pickup
│   └── Flag.swift              # goal node
├── Systems/
│   ├── PhysicsCategories.swift # bitmask categories cho contact
│   ├── InputState.swift        # struct: leftPressed, rightPressed, jumpPressed
│   └── LevelLoader.swift       # parse level JSON → SKTileMapNode + entities
├── Levels/
│   └── level-1-1.json          # tile grid + entity spawn data
├── Assets.xcassets/
│   ├── AppIcon.appiconset
│   ├── player-*.png            # placeholder sprites (32×32 hoặc 16×16 scaled)
│   ├── tiles-*.png
│   └── enemy-goomba-*.png
└── Sounds/                     # empty trong sprint 1, fill ở sprint 2
```

### 3.2 Module boundaries (mỗi module 1 mục đích)
- **GameScene** — orchestrator: sở hữu world, gọi systems mỗi update tick. Không chứa logic chi tiết.
- **Player** — state machine (idle/running/jumping/falling/dead). Đọc `InputState`, áp velocity vào physicsBody. Animation theo state.
- **Enemy** — protocol `Enemy` với `update(dt:)`; concrete `GoombaEnemy` đi patrol giữa 2 mép.
- **PhysicsCategories** — đơn 1 file static bitmask: `player=1<<0, enemy=1<<1, ground=1<<2, coin=1<<3, flag=1<<4, hazard=1<<5`.
- **LevelLoader** — input: tên level. Output: `(tilemap, [spawn point])`. Đọc JSON, sinh `SKTileMapNode` + danh sách entity spawn (player position, enemies, coins, flag).
- **TouchControls** — emit `InputState` ra delegate (GameScene), không đụng vào player trực tiếp → swap input method dễ (gamepad MFi sau này).

### 3.3 Data flow mỗi frame
```
SKScene.update(_:)
  → TouchControls.currentInputState
  → Player.update(input, dt)        // velocity, state transitions
  → Enemies.forEach { update(dt) }
SKScene.didSimulatePhysics
  → PhysicsContactDelegate          // stomp detection, coin pickup, hazard hit
  → Camera follow player.position
SKScene.didFinishUpdate
  → HUDOverlay.refresh(coins, lives)
```

### 3.4 Tile collision
- Dùng `SKTileMapNode` của SpriteKit + tự gen `SKPhysicsBody` cho từng solid tile (lúc load level, không runtime).
- Hoặc gen 1 `SKPhysicsBody.init(edgeChainFrom:)` cho mép trên ground để player đứng (perf tốt hơn).

### 3.5 Touch controls
- Bottom-left: 2 nút trái/phải (chồng cạnh nhau hoặc D-pad nhỏ).
- Bottom-right: 1 nút Jump (lớn, dễ chạm).
- Hit area lớn hơn visual để dễ chạm trên iPad.
- Vẫn hoạt động đa-điểm (đi + nhảy cùng lúc → `touchesBegan` track nhiều touch).

### 3.6 Asset placeholder strategy
- Sprint 1: dùng **CC0 / public domain tilesets** (kenney.nl có nhiều free assets platformer) để tránh đụng IP Nintendo ngay từ đầu — vẫn giúp gameplay test được.
- Hoặc dùng **placeholder hình chữ nhật màu** (player đỏ, enemy nâu, ground xám) để tập trung gameplay code trước, art sau.

---

## 4. Testing strategy

### Sprint 1
- **Unit test** logic độc lập: Player state machine transitions, LevelLoader parsing JSON, InputState merging.
- **Manual test** trên simulator: chơi qua màn, thử mọi cạnh — chạy vào rìa, nhảy quá đầu enemy, rơi xuống hố.
- **Device test** ít nhất 1 iPad + 1 iPhone trước khi đóng sprint.

### Sprint 2+
- Snapshot test cho menu UI.
- Performance: 60 fps trên iPhone đời cũ nhất supported.

---

## 5. Open Questions (cần chốt trước khi viết implementation plan Sprint 1)

1. **Pháp lý/IP path:** chọn (A) học tập nội bộ với art Mario, (B) original IP từ đầu, hay (C) start với CC0 placeholder rồi quyết sau?
2. **Min iOS version:** iOS 17 hay iOS 16? (iOS 17 cho phép dùng API mới nhưng cắt vài device cũ)
3. **Bundle ID** + **Apple Developer Team ID** — cần để Xcode signing. Lấy sau khi tạo project hay chốt trước?
4. **Asset source** sprint 1: kenney.nl free pack? Mario sprite ripped? Hay rectangle placeholder?
5. **Level format:** JSON tự định nghĩa (dễ code, ít tool) hay TMX từ Tiled editor (cần học Tiled, nhưng visual edit level)?
6. **Game Center / IAP** có nằm trong scope không (sprint 3 nói "optional")?
7. **Single dev hay team?** Ảnh hưởng tới convention, code review flow.

---

## 6. Trạng thái triển khai

- [x] Spec viết xong (file này)
- [ ] Chốt Open Questions với user
- [ ] Viết implementation plan cho Sprint 1 (skill `writing-plans`)
- [ ] Code Sprint 1
- [ ] Sprint 1 done → mở Sprint 2 spec
- [ ] ... → Sprint 4 → Submit App Store

---

## 7. Tham chiếu

- SpriteKit official docs: https://developer.apple.com/documentation/spritekit
- Kenney free game assets: https://kenney.nl/assets (CC0)
- Tiled level editor: https://www.mapeditor.org/
- Apple HIG — Games: https://developer.apple.com/design/human-interface-guidelines/games
- App Store Review Guidelines (IP section 5.2): https://developer.apple.com/app-store/review/guidelines/#intellectual-property

---

**Ghi chú cho session sau:**
Khi load lại file này để triển khai, bước đầu là **chốt Open Questions ở section 5**, rồi invoke skill `superpowers:writing-plans` để biến Sprint 1 thành implementation plan chi tiết (mỗi task có acceptance criteria + test plan).
