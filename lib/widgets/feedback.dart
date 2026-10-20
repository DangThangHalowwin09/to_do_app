import 'package:flutter/material.dart';

import '../core/utils/app_logger.dart';

/// Chạy một thao tác ghi dữ liệu và báo kết quả bằng SnackBar (thành công / thất bại).
/// Trả về `true` nếu thành công.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
  String failure = 'Thao tác thất bại, vui lòng thử lại',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (success != null) messenger.showSnackBar(SnackBar(content: Text(success)));
    return true;
  } catch (e) {
    AppLog.e(failure, e);
    messenger.showSnackBar(SnackBar(content: Text(failure)));
    return false;
  }
}
