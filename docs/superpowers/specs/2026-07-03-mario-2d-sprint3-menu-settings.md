# Mario 2D — Sprint 3: Menu, Settings & Accessibility — Design Spec

**Ngày:** 2026-07-03
**Trạng thái:** Draft
**Tiền đề:** Sprint 1 (MVP) + Sprint 2 (content & polish) đã xong — 91 unit tests pass, 5 màn playable, audio/parallax/animation. Xem [Sprint 2 spec](./2026-06-17-mario-2d-sprint2-content.md).
**Mục tiêu Sprint 3:** Hoàn thiện lớp "vỏ" quanh gameplay — title/pause/settings, haptic, accessibility, (optional) Game Center — để game hoàn chỉnh hơn, chuẩn bị cho Sprint 4 (submit).

---

## 1. Bối cảnh & nền tảng đã có

- `MenuScene` / `LevelSelectScene` / `SceneRouter` — khung điều hướng sẵn, chỉ cần thêm SettingsScene + pause.
- `AudioManager` — đã có cờ bật/tắt lưu UserDefaults; cần thêm volume + wiring vào settings UI.
- `ProgressStore` — có best-time mỗi màn → sẵn cho Game Center leaderboard.
- `TouchControls` — child của camera; cần thêm scale/layout tuỳ chỉnh.
- `ButtonNode` + `SKScene.tappedButton` — tái dùng cho mọi menu mới.

Ràng buộc giữ nguyên: Swift + SpriteKit, iOS 17, landscape, rectangle placeholder.

---

## 2. Scope Sprint 3

### 2.1 Title / Menu polish
- MenuScene: thêm nút **Settings**, animation tiêu đề, hiển thị tiến độ (đã qua N/5 màn).
- Chuyển cảnh mượt (đã có transition), thêm nút Settings ở LevelSelect.

### 2.2 Pause menu (trong game)
- Nút **Pause** (⏸) góc trên trong GameScene.
- Pause → dừng cập nhật + physics, hiện overlay: **Resume / Restart / Settings / Quit to Menu**.
- `isPaused` của SKScene/SKView để đóng băng; input controls vô hiệu khi pause.

### 2.3 Settings
- `SettingsScene` (hoặc overlay dùng chung menu + pause):
  - **Audio**: bật/tắt nhạc & SFX (đã có cờ), + volume (slider đơn giản: 3 mức Off/Low/High cho placeholder).
  - **Control layout**: kích thước nút (Small/Medium/Large) → áp vào TouchControls.
  - (optional) tay thuận: đảo D-pad/nút sang trái-phải.
- `SettingsStore` (mở rộng ý tưởng ProgressStore) lưu tất cả qua UserDefaults, inject được để test.

### 2.4 Haptic
- `HapticManager`: `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`.
- Kích khi: jump (light), stomp (medium), trúng đòn/chết (heavy/error), ăn power-up (success), coin (selection nhẹ).
- Tôn trọng cờ haptic on/off trong settings.

### 2.5 Accessibility
- **VoiceOver**: gán `isAccessibilityElement` + `accessibilityLabel` cho các nút menu (SKNode hỗ trợ accessibility qua `accessibilityLabel`/`accessibilityFrame`).
- **Control size scale**: setting kích thước nút (2.3) phục vụ luôn khả năng tiếp cận vận động.
- **Reduce motion**: nếu `UIAccessibility.isReduceMotionEnabled` → giảm parallax/animation.

### 2.6 Game Center leaderboard (OPTIONAL — chốt ở Open Questions)
- `GameCenterManager`: authenticate, submit best-time mỗi màn, hiển thị leaderboard.
- Cần entitlement + cấu hình App Store Connect → chỉ chạy device thật. Có thể để interface + stub, bật thật ở Sprint 4.

---

## 3. Architecture — phần thêm

```
mario/
├── Scenes/
│   ├── SettingsScene.swift      # UI settings (audio, control size, haptic)
│   └── PauseOverlay.swift        # overlay pause (node, không đổi scene)
├── Systems/
│   ├── SettingsStore.swift       # UserDefaults wrapper (audio vol, control size, haptic, handedness)
│   ├── HapticManager.swift       # UIFeedbackGenerator wrapper, tôn trọng cờ
│   └── GameCenterManager.swift    # (optional) authenticate + submit score
└── (sửa) MenuScene, LevelSelectScene, GameScene, TouchControls, AudioManager
```

### 3.1 SettingsStore (testable)
- Backing `KeyValueStore` (đã có protocol từ ProgressStore) → test bằng FakeStore.
- Keys: `audioEnabled` (chuyển từ AudioManager sang đây hoặc chia sẻ), `sfxVolume`, `bgmVolume`, `controlScale` (enum small/medium/large → CGFloat), `hapticEnabled`, `leftHanded`.
- AudioManager đọc volume từ SettingsStore.

### 3.2 Pause
- GameScene giữ `isPausedByUser`. Khi pause: `self.isPaused = true` (đóng băng actions + physics), hiện PauseOverlay trên camera (overlay không bị pause vì… thực ra child của scene cũng pause). → Dùng `view?.isPaused` cẩn thận; hoặc tự quản: set gameState = .paused, bỏ qua update/contact, hiện overlay, controls dừng. Overlay nút vẫn nhận touch (touch handler riêng, không phụ thuộc update loop).

### 3.3 Control scale
- `TouchControls.setup(designSize:scale:)` — nhân bán kính + vị trí nút theo scale. Đọc từ SettingsStore.

---

## 4. Testing strategy

### Unit test (mở rộng 91 test hiện có)
- `SettingsStore`: get/set mặc định, persistence, controlScale enum → CGFloat, clamp volume.
- `HapticManager`: tôn trọng cờ (disabled → không trigger; test qua injectable flag/spy).
- Pause logic trong GameScene: khi paused, update không tiến enemy/player (khó test scene trực tiếp → tách logic `shouldStep` nếu cần).
- `AudioManager`: đọc volume từ settings, áp vào player.volume.
- VoiceOver: nút có accessibilityLabel không rỗng.

### Manual / device
- Pause/resume giữa gameplay không lỗi state.
- VoiceOver bật: điều hướng menu đọc đúng nhãn.
- Haptic cảm nhận trên device thật.
- Control size thay đổi áp dụng ngay.

---

## 5. Open Questions

1. **Game Center**: làm thật (cần Apple Developer + ASC config) hay chỉ interface/stub Sprint 3, bật Sprint 4? (đề xuất: stub interface, bật Sprint 4)
2. **Settings UI**: SettingsScene riêng hay overlay dùng chung cho cả menu và pause? (đề xuất: 1 SettingsScene, mở từ cả 2 chỗ)
3. **Volume**: slider thật (cần custom SKNode slider) hay 3 mức Off/Low/High? (đề xuất: 3 mức cho nhanh, placeholder)
4. **Haptic mapping**: mức độ từng event (light/medium/heavy) — chốt bảng.
5. **Left-handed mode** có nằm trong scope Sprint 3 không? (đề xuất: có, rẻ khi đã có control layout)

---

## 6. Trạng thái triển khai

- [x] Spec viết xong (file này)
- [ ] Code Sprint 3
  - [x] Step 1: SettingsStore + SettingsScene (audio/bgm/sfx, cỡ nút, tay thuận, rung) — +8 tests
  - [x] Step 3: HapticManager + cắm 6 event trong GameScene + menu
  - [x] Step 4: Control scale + left-handed áp vào TouchControls (đọc SettingsStore)
  - [x] Step 2: Pause menu (nút II → overlay Resume/Restart/Settings/Menu, freeze physics)
  - [x] Step 5: Accessibility (VoiceOver label cho ButtonNode + reduce motion cho parallax) — +3 tests
  - [x] Step 6: GameCenterManager (authenticate + submit best-time, no-op an toàn khi chưa config) — +4 tests
- [ ] Test device thật → đóng Sprint 3

**Sprint 3 CODE HOÀN TẤT** (2026-07-03): 105 unit tests pass, build + launch OK. Settings/pause/haptic/accessibility/Game Center stub xong. Còn: bật Game Center thật (entitlement + ASC) ở Sprint 4 + test device thật.
- [ ] Sprint 3 done → mở Sprint 4 (original IP + submit App Store)

**Default chọn:** Game Center = stub Sprint 3; Settings = 1 scene chung; volume 3 mức; left-handed = có.

---

## 7. Thứ tự thực thi

1. **SettingsStore** (pure logic, test trước).
2. **HapticManager** (wrapper nhỏ, test cờ).
3. **SettingsScene** (UI, đọc/ghi store).
4. **Control scale + left-handed** vào TouchControls.
5. **Pause menu** trong GameScene.
6. **Accessibility** (VoiceOver labels + reduce motion).
7. (optional) **GameCenterManager**.

Mỗi bước commit riêng + `xcodebuild test` xanh.
