import 'package:flutter/material.dart';

/// Bảng màu dùng chung toàn app (thay cho các mã màu rải rác trong từng màn hình).
class AppColors {
  AppColors._();

  static const Color red = Color(0xFFCE3531);
  static const Color blue = Color(0xFF00408C);

  /// Màu nền thanh tiêu đề của các màn hình sau đăng nhập.
  static const Color header = Color(0xFF3A4C7A);

  /// Màu phụ của dòng mô tả dưới tên app.
  static const Color tagline = Color(0xFFD01F26);
}
