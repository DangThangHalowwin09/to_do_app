import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/app_logger.dart';

/// Ghi nhớ thiết bị này đã xem màn hình giới thiệu chưa.
class OnboardingStore {
  OnboardingStore._();

  static const _key = 'onboarding_seen_v1';

  /// Lỗi đọc bộ nhớ coi như đã xem để không chặn người dùng vào app.
  static Future<bool> hasSeen() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_key) ?? false;
    } catch (e) {
      AppLog.e('Không đọc được trạng thái giới thiệu', e);
      return true;
    }
  }

  static Future<void> markSeen() async {
    try {
      await (await SharedPreferences.getInstance()).setBool(_key, true);
    } catch (e) {
      AppLog.e('Không lưu được trạng thái giới thiệu', e);
    }
  }
}
