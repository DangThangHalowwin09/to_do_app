import 'package:flutter/material.dart';

/// Bảng màu dùng chung. Màu thương hiệu lấy từ logo bệnh viện (xanh + đỏ).
/// Mọi cặp chữ/nền ở đây đạt tương phản >= 4.5:1.
class AppColors {
  AppColors._();

  // Thương hiệu
  static const Color blue = Color(0xFF00408C);
  static const Color blueDark = Color(0xFF002B61);
  static const Color red = Color(0xFFCE3531);

  // Nền và chữ
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF14213D);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color border = Color(0xFFD8E0EC);

  // Trạng thái công việc (luôn đi kèm biểu tượng + chữ, không chỉ dùng màu)
  static const Color pending = Color(0xFFB45309); // chờ xử lý (cam đậm)
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color progress = Color(0xFF00408C); // đang xử lý
  static const Color progressBg = Color(0xFFDCEAFB);
  static const Color done = Color(0xFF166534); // hoàn thành
  static const Color doneBg = Color(0xFFDCFCE7);
  static const Color urgent = Color(0xFFB42318); // khẩn / lỗi
  static const Color urgentBg = Color(0xFFFEE4E2);

  /// Màu nền thanh tiêu đề các màn hình sau đăng nhập.
  static const Color header = blue;

  /// Màu phụ của dòng mô tả dưới tên app.
  static const Color tagline = Color(0xFFB42318);
}
