# App Store Connect — Metadata "Super Square"

Soạn sẵn để copy-paste khi điền App Store Connect. Chỉnh theo ý bạn.

---

## Thông tin cơ bản
- **App Name:** Super Square
- **Subtitle (30 ký tự):** Nhảy, đập, về đích
- **Bundle ID:** com.datnm555.supersquare
- **SKU:** supersquare-001
- **Primary Category:** Games
- **Secondary Category:** Games → Arcade (hoặc Action)
- **Price:** Free
- **Primary Language:** Vietnamese (hoặc English tuỳ bạn)

---

## Description (Tiếng Việt)
```
Super Square là game platformer 2D tối giản: điều khiển một khối vuông đỏ chạy,
nhảy, giẫm quái, ăn nấm to ra và bắn lửa để về đích qua 5 màn chơi.

TÍNH NĂNG
• 5 màn với độ khó tăng dần — từ dễ làm quen tới thử thách né hố, né quái
• 3 loại kẻ địch: bộ hành, mai rùa (đá cho trượt!), quái bay
• Power-up: nấm lớn lên (chịu thêm 1 đòn), hoa lửa (bắn đạn)
• Đập khối ? để nhả coin và vật phẩm
• Điều khiển cảm ứng: D-pad + nút nhảy + nút bắn, chỉnh cỡ nút & tay thuận
• Nhạc nền + hiệu ứng, phản hồi rung
• Lưu tiến độ, ghi thời gian nhanh nhất mỗi màn
• Hỗ trợ VoiceOver, giảm chuyển động

Phong cách hình khối tối giản, chơi nhanh, không quảng cáo, không mua trong ứng dụng.
```

## Description (English)
```
Super Square is a minimalist 2D platformer: guide a little red square as it runs,
jumps, stomps foes, grows with mushrooms and shoots fireballs to reach the flag
across 5 handcrafted levels.

FEATURES
• 5 levels with a rising difficulty curve
• 3 enemy types: walkers, shells (kick them to slide!), and flyers
• Power-ups: mushroom (take an extra hit), fire flower (shoot fireballs)
• Bump ? blocks for coins and items
• Touch controls with adjustable size and left-handed mode
• Music, sound effects, and haptics
• Progress saving and per-level best times
• VoiceOver and Reduce Motion support

Clean geometric art, quick to play, no ads, no in-app purchases.
```

---

## Keywords (100 ký tự, phẩy ngăn)
```
platformer,arcade,jump,retro,pixel,run,casual,2d,minimal,square,offline,fun
```

## Promotional Text (170 ký tự)
```
Một khối vuông đỏ, 5 màn, nhảy và né quái về đích. Không quảng cáo, không IAP — chơi là vui.
```

---

## Age Rating (điền questionnaire → dự kiến 9+)
- Cartoon or Fantasy Violence: **Infrequent/Mild** (giẫm quái, hình khối, không máu)
- Tất cả mục khác: **None**
- → Kết quả thường là **9+** (hoặc 4+ nếu Apple xếp bạo lực khối là None).

## Privacy (App Privacy)
- **Data Collection:** No — "Data Not Collected"
- Khớp `PrivacyInfo.xcprivacy` (no tracking, no data).
- **Privacy Policy URL:** cần 1 trang (xem mẫu dưới) — vd host GitHub Pages.

### Mẫu Privacy Policy (host ở đâu đó, dán URL vào ASC)
```
Super Square không thu thập, lưu trữ hay chia sẻ bất kỳ dữ liệu cá nhân nào.
Tiến độ chơi được lưu cục bộ trên thiết bị của bạn (UserDefaults) và không rời khỏi máy.
Ứng dụng không có quảng cáo, không mua trong ứng dụng, không theo dõi.
Liên hệ: <email của bạn>
```

---

## URLs cần
- **Support URL:** trang liên hệ (GitHub repo hoặc trang đơn giản)
- **Marketing URL (optional)**

---

## Screenshots (bắt buộc)
Landscape. Chụp từ simulator (Claude giúp được):
- **iPhone 6.9"/6.7"** (bắt buộc): iPhone 16 Pro Max — 2796×1290 landscape
- **iPad 13"** (bắt buộc nếu hỗ trợ iPad): iPad Pro 13" — 2732×2048 landscape
- 3–5 ảnh: menu, gameplay 1-1, ăn power-up, boss màn 1-5, màn hình win.
- Lệnh gợi ý: chạy app với `--args -startLevel N`, `xcrun simctl io <dev> screenshot`.

---

## Checklist submit (Claude giúp phần code, USER bấm nút)
- [x] Icon 1024 không alpha ✅ (đã có)
- [x] Bundle id / display name ✅
- [x] Privacy manifest ✅
- [ ] Apple Developer Program active (USER)
- [ ] Signing team trong Xcode (USER)
- [ ] Privacy Policy URL live (USER host)
- [ ] Screenshots đúng size (Claude chụp, USER upload)
- [ ] Archive → upload TestFlight (USER, Xcode)
- [ ] Test trên device thật iPhone + iPad (USER)
- [ ] Điền metadata trên (USER copy-paste)
- [ ] Submit for Review (USER)
