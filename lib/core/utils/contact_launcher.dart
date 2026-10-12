import 'package:url_launcher/url_launcher.dart';

import 'app_logger.dart';

/// Mở các ứng dụng ngoài: gọi điện, Zalo, Facebook, trình duyệt...
class ContactLauncher {
  ContactLauncher._();

  static Future<void> call(String phoneNumber) =>
      _open(Uri.parse('tel://$phoneNumber'));

  /// Ưu tiên mở app Zalo, nếu không có thì mở zalo.me.
  static Future<void> zalo(String phoneNumber) async {
    final app = Uri.parse('zalo://conversation?phone=$phoneNumber');
    if (await canLaunchUrl(app)) {
      await launchUrl(app, mode: LaunchMode.externalApplication);
      return;
    }
    await _open(Uri.parse('https://zalo.me/$phoneNumber'));
  }

  /// Mở bất kỳ URL (web, Facebook, TikTok...) bằng ứng dụng ngoài.
  static Future<void> url(String url) => _open(Uri.parse(url));

  static Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLog.d('Không thể mở: $uri');
    }
  }
}
