/// Cấu hình truyền lúc build bằng `--dart-define=TÊN=giá_trị`.
class AppConfig {
  AppConfig._();

  /// Khoá VAPID cho Web Push (Firebase Console → Project settings → Cloud Messaging
  /// → Web Push certificates). Để trống thì bản web không đăng ký nhận thông báo đẩy
  /// (vẫn xem được thông báo trong mục "Thông báo" của app).
  static const String webVapidKey = String.fromEnvironment('FCM_VAPID_KEY');
}
