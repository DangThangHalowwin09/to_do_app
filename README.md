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
