import 'package:flutter/foundation.dart';

/// Log chỉ in ở chế độ debug, tránh lộ dữ liệu (token, thông tin user) trong bản release.
class AppLog {
  AppLog._();

  static void d(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    debugPrint('$message${error != null ? ': $error' : ''}');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}
