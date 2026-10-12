/// Tên route và khoá dữ liệu dùng cho push notification.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String updateProfile = '/updateProfile';
  static const String task = '/task';
  static const String error = '/error';
}

/// Khoá trong `RemoteMessage.data` để điều hướng khi bấm thông báo.
class PushDataKeys {
  PushDataKeys._();

  static const String type = 'type';
  static const String id = 'id';

  static const String taskType = 'task';
  static const String errorType = 'error';
}
