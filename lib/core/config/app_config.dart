/// Cấu hình có thể ghi đè khi build:
/// `flutter build apk --dart-define=PUSH_SERVER_URL=http://<ip>:5000`
class AppConfig {
  AppConfig._();

  /// Máy chủ trung gian gửi FCM (endpoint `/send-notification`).
  static const String pushServerUrl = String.fromEnvironment(
    'PUSH_SERVER_URL',
    defaultValue: 'http://192.168.1.10:5000',
  );
}
