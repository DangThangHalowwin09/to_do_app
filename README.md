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
# Máy chủ gửi thông báo đẩy (mặc định http://192.168.1.10:5000):
flutter run --dart-define=PUSH_SERVER_URL=http://<ip>:5000
```
