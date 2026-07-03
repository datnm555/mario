# Mario 2D — Sprint 4: Original IP & Submit App Store — Design Spec

**Ngày:** 2026-07-03
**Trạng thái:** Draft
**Tiền đề:** Sprint 1–3 xong — game platformer hoàn chỉnh (5 màn, enemy/power-up/block/pipe, audio, parallax, menu/settings/pause/haptic/accessibility/GameCenter stub), 105 unit tests pass, build + launch OK.
**Mục tiêu Sprint 4:** Đưa game lên **App Store** — làm sạch IP, hoàn thiện branding/asset, cấu hình developer account + App Store Connect, TestFlight, submit review, launch.

> ⚠️ Sprint 4 phần lớn là **việc ngoài code** (đăng ký tài khoản, thanh toán, tạo art, điền metadata, chờ review). Nhiều bước **cần user thao tác trực tiếp** (Apple ID, thẻ thanh toán, quyết định thẩm mỹ). Claude hỗ trợ: code còn thiếu, checklist, text metadata, cấu trúc asset.

---

## 1. Tin tốt về IP

Vì Sprint 1 đã chọn **rectangle placeholder** (không dùng sprite/tên Nintendo), dự án **gần như đã sạch IP sẵn**:
- ✅ Không art Mario/Goomba/Koopa (toàn hình khối màu)
- ✅ Tên game "SUPER SQUARE" (gốc), không "Mario"
- ✅ Âm thanh WAV tự sinh (không rip)
- ✅ Level tự thiết kế

**Cần rà (audit) trước submit:**
- Tên biến/comment nội bộ còn "goomba/koopa/mario" — KHÔNG ảnh hưởng review (Apple không đọc code) nhưng nên đổi tên hiển thị & bundle. Cân nhắc rename symbol cho chuyên nghiệp (optional).
- Bundle ID `com.example.mario` → đổi thành domain thật của bạn, tên không chứa "mario" nếu muốn tránh hiểu lầm (vd `com.<bạn>.supersquare`).
- Cơ chế gameplay (platformer, giẫm đầu, ăn nấm to ra) **không bảo hộ được** → an toàn. Chỉ art/tên/nhân vật mới là IP.

**Kết luận:** đây là **original game** hợp lệ để submit. Chỉ cần polish branding, không phải làm lại art từ IP.

---

## 2. Scope Sprint 4

### 2.A Code/asset còn thiếu (Claude làm được phần lớn)
1. **App Icon** — bộ icon 1024×1024 (+ các size). Hiện `AppIcon.appiconset` rỗng. Cần 1 icon gốc (có thể vẽ hình khối đơn giản khớp "SUPER SQUARE").
2. **Bundle ID + Display Name** — đổi `PRODUCT_BUNDLE_IDENTIFIER`, `INFOPLIST_KEY_CFBundleDisplayName = "Super Square"`.
3. **Version/Build** — `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1` (sẵn rồi).
4. **Privacy Manifest** (`PrivacyInfo.xcprivacy`) — game không thu thập dữ liệu → khai "no data collected"; khai API usage (UserDefaults) nếu cần.
5. **Game Center thật** (nếu bật): entitlement `com.apple.developer.game-center`, capability trong project, tạo leaderboard trên ASC khớp `time_level_1..5`.
6. **Launch screen** — đang dùng generated; OK, có thể thêm màu nền khớp brand.
7. **Rà accessibility & orientation** — landscape lock đã có; kiểm iPad multitasking (có thể cần `UIRequiresFullScreen`).
8. (optional) Đổi tên symbol Goomba/Koopa → generic (Walker/Shellfoe...) cho sạch.

### 2.B Tài khoản & pháp lý (USER làm)
9. **Apple Developer Program** — đăng ký $99/năm (cần Apple ID + thẻ).
10. **Signing** — Team ID, certificate, provisioning (Xcode tự động khi đăng nhập account).
11. **Privacy Policy URL** — App Store yêu cầu (dù không thu data, vẫn cần 1 trang; có thể host GitHub Pages).

### 2.C App Store Connect (USER điền, Claude soạn text)
12. Tạo app record: tên "Super Square", primary language, bundle ID, SKU.
13. **Metadata**: mô tả, keywords, category (Games > Arcade/Platformer), age rating (điền questionnaire → ~4+/9+).
14. **Screenshots**: bắt buộc iPhone 6.7"/6.5" + iPad 12.9" (landscape). Claude giúp chụp từ simulator.
15. **App Preview** (video, optional).
16. **Pricing**: Free (đề xuất) / Paid.
17. **Privacy nutrition label**: "Data Not Collected".

### 2.D TestFlight & Submit (USER thao tác, Claude hỗ trợ)
18. Archive (Xcode) → upload build lên ASC.
19. TestFlight internal test (tự mình) → external (optional).
20. Submit for Review, trả lời App Review nếu hỏi.
21. Release (manual/auto) khi approved.

---

## 3. Checklist tiền-submit (Apple Review Guidelines hay reject)

- [ ] Icon đủ mọi size, không alpha, không trong suốt (1024 không alpha).
- [ ] Screenshots đúng resolution device bắt buộc, đúng orientation.
- [ ] Không crash khi launch (đã verify simulator; cần device thật).
- [ ] Không placeholder text "Lorem"/"example" hiển thị cho user.
- [ ] Bundle ID không chứa từ khoá gây hiểu lầm IP.
- [ ] Không dùng API riêng tư; Privacy Manifest khai đúng.
- [ ] Game Center (nếu bật) hoạt động hoặc gỡ hẳn trước submit (không để nút chết).
- [ ] Age rating khớp nội dung (bạo lực hoạt hình nhẹ = giẫm enemy → ~9+? điền questionnaire).
- [ ] Có Privacy Policy URL.
- [ ] Support URL (trang liên hệ).
- [ ] Test trên device thật iPhone + iPad (tiêu chí done Sprint 1–3 còn treo).

---

## 4. Testing strategy

- **Device thật**: chơi trọn 5 màn trên iPhone + iPad, kiểm 60fps, touch, haptic, audio, pause, settings, orientation.
- **TestFlight**: cài qua TestFlight ít nhất 1 vòng trước submit.
- **Unit tests**: giữ 105 test xanh; thêm test cho code mới (privacy/entitlement không unit-test được — manual).
- **Xcode Organizer**: kiểm validation trước upload (bắt lỗi icon/entitlement sớm).

---

## 5. Open Questions

1. **Bundle ID / domain**: dùng domain nào? (cần cho bundle id + email support). Chưa có thì `com.<githubuser>.supersquare`.
2. **Rename symbol** Goomba/Koopa/"mario" project name → generic? (đề xuất: đổi Display Name + bundle, giữ tên file/symbol để đỡ rủi ro; hoặc rename toàn bộ nếu muốn sạch tuyệt đối).
3. **Game Center**: bật thật (tốn công ASC + entitlement) hay gỡ nút/stub và để Sprint sau? (đề xuất: gỡ khỏi UI nếu chưa config, tránh nút chết bị reject — hiện chưa có UI leaderboard nên an toàn).
4. **Pricing**: Free hay Paid?
5. **Art**: giữ rectangle "hình khối tối giản" làm phong cách chính thức (hợp lệ, minimal-art game có chỗ đứng) hay thuê/vẽ sprite thật trước launch? (đề xuất: giữ minimal cho v1.0, sprite ở update sau).
6. **App icon**: Claude vẽ icon hình khối bằng code/SVG hay bạn tự thiết kế?
7. Có cần **localization** (EN + VI) cho metadata không?

---

## 6. Trạng thái triển khai

- [x] Spec viết xong (file này)
- [x] Chốt Open Questions: icon = Claude vẽ minimal · Game Center = giữ stub (không entitlement, không UI → không nút chết) · pricing = Free · bundle = com.datnm555.supersquare
- [x] 2.A Code/asset: app icon (ô đỏ + cloud + coin), bundle id `com.datnm555.supersquare`, display name "Super Square", PrivacyInfo.xcprivacy (no data collected). Build + 105 tests pass, launch OK. **Game Center: giữ stub, không thêm UI/entitlement.**
- [ ] 2.B Apple Developer Program + signing (USER)
- [ ] 2.C App Store Connect record + metadata + screenshots
- [ ] 2.D Archive → TestFlight → Submit → Review → Launch
- [ ] 🚀 Live trên App Store

---

## 7. Chi phí & thời gian ước tính

- **Chi phí**: Apple Developer $99/năm (bắt buộc). Art/icon: $0 nếu tự làm minimal.
- **Thời gian**: code/asset 2.A ~0.5–1 ngày (Claude); tài khoản + ASC + screenshots ~1 ngày (user); review Apple ~1–3 ngày chờ.
- **Rủi ro reject thường gặp**: icon sai spec, screenshots thiếu size, nút Game Center chết, thiếu privacy policy → checklist mục 3 để tránh.

---

## 8. Bước kế tiếp ngay

1. **Chốt Open Questions** (bundle ID, pricing, Game Center giữ/gỡ, ai làm icon).
2. Claude làm **2.A** (phần code/asset không cần tài khoản): app icon placeholder gốc, đổi bundle id/display name, privacy manifest, gỡ hoặc hoàn thiện Game Center.
3. User đăng ký **Apple Developer** song song.
4. Ghép lại ở bước ASC + submit.

**Ghi chú:** Claude KHÔNG thể tự đăng ký tài khoản, thanh toán, hay bấm Submit thay bạn — những bước đó cần bạn. Claude lo hết phần code/asset/text.
