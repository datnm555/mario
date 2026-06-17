# Mario 2D — Sprint 2: Content & Polish — Design Spec

**Ngày:** 2026-06-17
**Trạng thái:** Draft (cần chốt Open Questions trước khi viết implementation plan)
**Tiền đề:** Sprint 1 MVP đã xong — build & run OK, 35 unit tests pass. Xem [`2026-06-17-mario-2d-ios-design.md`](./2026-06-17-mario-2d-ios-design.md) section 6.
**Mục tiêu Sprint 2:** Biến 1 màn vertical-slice thành 1 game có **nội dung** (nhiều màn, nhiều enemy, power-up) và **polish** (animation, audio, parallax, save).

---

## 1. Bối cảnh

Sprint 1 đã có nền tảng data-driven sẵn sàng mở rộng:
- `LevelLoader` đọc JSON ASCII grid → chỉ cần thêm file level + ký tự legend mới.
- `Enemy` là protocol → thêm loại enemy = thêm class conform.
- `TouchControls` emit `InputState` → không đụng khi thêm power-up.
- `PhysicsCategories` bitmask đã chừa sẵn `hazard`; cần thêm vài category mới.

**Ràng buộc giữ nguyên:** Swift + SpriteKit, iOS 17, landscape, iPhone+iPad, rectangle placeholder (art thật để Sprint 4). Vẫn KHÔNG submit (IP + chưa polish đủ).

---

## 2. Scope Sprint 2 (theo roadmap mục 47–55 của spec gốc)

### 2.1 Content
- **3–5 màn** chơi: `level-1-1.json` … `level-1-5.json`. Mỗi màn 1 file, độ khó tăng dần.
- **Level select / world map đơn giản**: màn hình chọn màn (grid nút), unlock tuần tự theo tiến độ.
- **2 enemy mới** (ngoài Goomba):
  - `KoopaEnemy` (turtle-like): stomp → rút vào mai (shell); stomp/đá shell → shell trượt giết enemy khác; chạm shell đứng yên → đẩy đi.
  - `FlyingEnemy`: bay theo quỹ đạo (sin wave hoặc patrol dọc), stomp được.
- **Power-up:**
  - `Mushroom` → player "lớn" (size + 1 hit buffer: trúng đòn mất power thay vì chết).
  - `FireFlower` → player bắn `Fireball` (projectile, giết enemy từ xa, có cooldown).
- **Hidden block** (`?` block): đập từ dưới → nhả coin hoặc power-up.
- **Pipe / ống xanh**: vật cản solid; (optional) transport giữa 2 điểm khi nhấn xuống.

### 2.2 Polish
- **Animation theo state**: idle/run/jump/fall/hurt/victory. Sprint 1 đang đổi màu → thay bằng sprite-sheet `SKAction` animation (placeholder vẫn rectangle nhưng có khung animation sẵn).
- **Background parallax**: 2–3 lớp nền cuộn với tốc độ khác nhau theo camera.
- **Audio**:
  - BGM mỗi world (loop).
  - SFX: jump, coin, stomp, power-up, fireball, death, level-clear.
  - `AudioManager` (singleton) preload + play; tôn trọng mute setting.
- **Save progress**: `UserDefaults` — max level cleared, tổng coin. Có `ProgressStore` tách riêng (testable).

---

## 3. Architecture — phần thêm vào Sprint 1

### 3.1 File mới (giữ nguyên module boundaries)
```
mario/
├── App/
│   └── (giữ nguyên; ContentView host scene đầu tiên = MenuScene)
├── Scenes/
│   ├── MenuScene.swift          # title + nút Play
│   ├── LevelSelectScene.swift   # chọn màn, hiển thị unlock
│   └── GameScene.swift          # +nhận levelName từ ngoài, +power-up state
├── Entities/
│   ├── KoopaEnemy.swift         # conform Enemy
│   ├── FlyingEnemy.swift        # conform Enemy
│   ├── Mushroom.swift           # power-up pickup
│   ├── FireFlower.swift         # power-up pickup
│   ├── Fireball.swift           # projectile player bắn
│   └── QuestionBlock.swift      # hidden block
├── Systems/
│   ├── AudioManager.swift       # BGM + SFX
│   ├── ProgressStore.swift      # UserDefaults wrapper (testable qua protocol)
│   ├── SceneRouter.swift        # chuyển scene (menu ↔ select ↔ game) + transition
│   └── LevelLoader.swift        # +legend mới: K koopa, Y flying, M mushroom,
│                                #   ? block, T pipe
├── Components/
│   ├── ParallaxBackground.swift # SKNode nhiều lớp
│   └── AnimationLibrary.swift   # map state → SKAction (placeholder frames)
├── Levels/
│   └── level-1-1.json … 1-5.json
└── Sounds/                      # .wav/.caf SFX + .mp3 BGM (CC0/placeholder beep)
```

### 3.2 Thay đổi cốt lõi
- **PhysicsCategories**: thêm `powerup = 1<<6`, `projectile = 1<<7`, `block = 1<<8`. (`hazard` đã có.)
- **Player**: thêm enum `PowerState { small, big, fire }`; trúng đòn: fire→big→small→chết. Thêm `shootFireball()` khi `.fire`. Size/hitbox đổi theo power.
- **GameScene**: nhận `levelName` qua init (router truyền vào); khi clear → gọi `ProgressStore.markCleared` + chuyển LevelSelect. Tách overlay win/lose ra dùng chung.
- **Enemy protocol**: thêm `func onPlayerContact(from side:) -> EnemyHitResult` để chuẩn hoá stomp/shell/hurt thay vì hardcode trong GameScene.

### 3.3 Scene flow
```
MenuScene --Play--> LevelSelectScene --chọn màn--> GameScene(level)
GameScene --clear--> ProgressStore.markCleared --> LevelSelectScene (màn mới unlock)
GameScene --hết mạng--> LevelSelectScene
```

---

## 4. Testing strategy

### Unit test (mở rộng từ 35 test hiện có)
- `ProgressStore`: markCleared, isUnlocked, persistence (inject fake UserDefaults).
- `LevelLoader`: parse legend mới (K/Y/M/?/T) → đúng spawn list.
- `Player` power state machine: fire→big→small→dead; shootFireball chỉ khi `.fire`.
- `KoopaEnemy`: stomp → shell; shell moving giết enemy; idle shell bị đẩy.
- `Fireball`: bay + cooldown + tự huỷ khi chạm tường/enemy.
- `AnimationLibrary`: trả đúng SKAction cho mỗi state (không nil).

### Manual / device
- Chơi qua 5 màn, thử mọi power-up + enemy combo.
- 60 fps trên iPhone đời cũ nhất supported (Instruments).
- Snapshot test Menu + LevelSelect (optional, theo spec gốc sprint 2).

---

## 5. Open Questions (chốt trước khi viết plan)

1. **Số màn:** 3 hay 5 cho lần này? (ảnh hưởng effort design level)
2. **Pipe transport:** làm full (warp giữa điểm) hay chỉ làm vật cản solid trong Sprint 2?
3. **Audio asset:** CC0 pack (kenney/freesound) hay beep tự generate bằng code (AVAudioEngine) cho placeholder?
4. **Animation placeholder:** giữ rectangle + đổi scale/màu theo khung, hay import 1 sprite-sheet CC0 ngay để dựng pipeline animation thật?
5. **Koopa shell** có giết enemy khác không (cơ chế phức tạp hơn) hay chỉ rút mai rồi biến mất?
6. **Level select** kiểu world-map (node nối nhau) hay grid nút đơn giản? (đề xuất: grid cho nhanh)
7. **Save:** chỉ max-level + coin, hay thêm best-time mỗi màn (chuẩn bị cho Game Center Sprint 3)?

---

## 6. Trạng thái triển khai

- [x] Spec viết xong (file này)
- [ ] Chốt Open Questions với user
- [ ] Viết implementation plan Sprint 2 (skill `writing-plans`) — chia task có acceptance criteria
- [ ] Code Sprint 2 (đề xuất thứ tự: ProgressStore → SceneRouter/Menu → enemy mới → power-up → audio → parallax → 5 màn → polish)
- [ ] Test device thật → đóng Sprint 2
- [ ] Sprint 2 done → mở Sprint 3 (menu/settings/accessibility)

---

## 7. Đề xuất thứ tự thực thi (giảm rủi ro)

1. **ProgressStore** (pure logic, test trước — không cần SpriteKit).
2. **SceneRouter + MenuScene + LevelSelectScene** (khung điều hướng, GameScene nhận levelName).
3. **Enemy mới** (Koopa, Flying) — tái dùng pattern Goomba.
4. **Power-up** (Mushroom → Player.PowerState → FireFlower/Fireball).
5. **QuestionBlock + Pipe**.
6. **AudioManager** (cắm SFX vào event có sẵn).
7. **ParallaxBackground + AnimationLibrary** (polish hình ảnh).
8. **Thiết kế 5 màn** + cân bằng độ khó.
9. Manual + device test.

Mỗi bước commit riêng + chạy `xcodebuild test` giữ test xanh.
