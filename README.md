# UBNA Manager (flutter_to_do_list)

Ứng dụng nội bộ hỗ trợ nhân viên bệnh viện: báo lỗi CNTT, giao việc phòng IT, tra cứu lịch trực,
kiểm tra lỗi BHXH, tin tức. Dữ liệu và đăng nhập dùng Firebase (Auth, Firestore, Storage, Messaging).

## Cấu trúc `lib/`

| Thư mục | Vai trò |
| --- | --- |
| `main.dart`, `app.dart` | Khởi động app, `MaterialApp`, chọn màn hình theo trạng thái đăng nhập |
| `core/constants` | `UserRole` (vai trò), `AppColors`, `AppRoutes` / `PushDataKeys` |
| `core/utils` | Hàm thuần: `DutySchedule` (xoay vòng lịch trực), link Drive, mở app ngoài, log |
| `core/config` | Cấu hình build (`--dart-define=PUSH_SERVER_URL=...`) |
| `services/` | Auth, `UserSession` (người dùng hiện tại), FCM, thông báo cục bộ, upload ảnh |
| `repositories/` | Truy vấn Firestore theo nghiệp vụ (lỗi, nhiệm vụ, lịch trực, nhân viên, khu vực) |
| `models/` | Model dữ liệu |
| `screens/` | Các màn hình, chia theo chức năng (`auth/`, `home/`, `errors/`, `tasks/`...) |
| `widgets/` | Widget dùng lại nhiều nơi |

## Luồng đăng nhập

`MyApp` (theo `authStateChanges`) → chưa đăng nhập: `GeneralInformationScreen`;
đã đăng nhập: `RoleRedirectScreen` → nạp `UserSession` → thiếu hồ sơ thì `FinishProfileScreen`,
đủ hồ sơ thì `HomeScreen(role)`. Chức năng của từng vai trò khai báo ở `screens/home/home_menu.dart`.

## Chạy và kiểm tra

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Thông báo đẩy (push)

App chỉ **nhận** thông báo (`services/firebase_messaging_service.dart`). Việc **gửi** do Cloud Functions
trong `functions/` đảm nhiệm, tự chạy khi dữ liệu Firestore thay đổi:

| Sự kiện | Ai nhận |
| --- | --- |
| Có phiếu `errors` mới | Tổ phần mềm (lỗi phần mềm) / Tổ phần cứng phụ trách khu vực của bác sỹ (lỗi phần cứng) |
| IT nhận xử lý / hoàn thành phiếu | Bác sỹ đã báo lỗi |
| Giao việc `tasks` mới hoặc đổi người nhận | Người được giao |

Token thiết bị lưu ở `users/{uid}.fcmTokens` (mảng, nhiều thiết bị). Triển khai (một lần, cần gói Blaze):

```bash
npm install -g firebase-tools && firebase login
cd functions && npm install && npm test && cd ..
firebase deploy --only functions
```

## CI/CD (GitHub Actions)

| Workflow | Khi nào chạy | Làm gì |
| --- | --- | --- |
| `ci.yml` | mỗi push / pull request | `flutter analyze`, `flutter test`, test Cloud Functions |
| `build-android.yml` | chạy tay hoặc đẩy tag `v*` | build APK + AAB (tải ở mục Artifacts của lần chạy) |
| `deploy-functions.yml` | push vào nhánh chính khi `functions/` đổi, hoặc chạy tay | deploy Cloud Functions |

Cấu hình **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Dùng cho | Cách tạo |
| --- | --- | --- |
| `FIREBASE_SERVICE_ACCOUNT` | deploy Functions | Nội dung file JSON của service account chỉ có quyền deploy Functions |
| `ANDROID_KEYSTORE_BASE64` | ký bản release | `base64 -w0 my-release-key.keystore` |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | ký bản release | Thông tin trong `android/key.properties` của bạn |

Chưa có secret keystore thì bản build dùng khoá debug (không dùng để phát hành). Phiên bản Flutter ghim ở
biến `FLUTTER_VERSION` trong các workflow; đổi cho khớp máy bạn khi nâng cấp.

## Công cụ cho Claude Code

Dự án có sẵn (commit trong repo, ai clone về cũng dùng được):
- `.claude/skills/ui-ux-pro-max/` — skill tư vấn thiết kế UI/UX (nguồn: nextlevelbuilder/ui-ux-pro-max-skill, giấy phép MIT, commit `56ea9cf`). Hỗ trợ stack Flutter.
- `.mcp.json` — Playwright MCP để Claude mở trình duyệt và kiểm thử bản web.

Để dùng cho **mọi dự án** trên máy bạn: `bash scripts/setup-claude-tools.sh`.

Kiểm thử bản web Flutter bằng Playwright: Flutter web vẽ lên canvas nên cần bật cây "semantics" (Claude sẽ
bấm nút "Enable accessibility" ở góc trang) hoặc chạy với `--web-renderer html` trên bản Flutter còn hỗ trợ.
