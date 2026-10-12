import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/utils/app_logger.dart';

/// Gửi thông báo đẩy tới một thiết bị thông qua máy chủ trung gian.
class PushNotificationSender {
  PushNotificationSender._();

  static Future<void> send({
    required String targetToken,
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.pushServerUrl}/send-notification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': {
                'token': targetToken,
                'notification': {'title': title, 'body': body},
                'data': data,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));
      AppLog.d('Gửi notification: ${response.statusCode} ${response.body}');
    } catch (e) {
      AppLog.e('Lỗi khi gửi notification', e);
    }
  }
}
