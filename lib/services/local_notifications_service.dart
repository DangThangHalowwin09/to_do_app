import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Hiển thị thông báo cục bộ (dùng khi nhận push lúc app đang mở trên Android).
class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService instance = LocalNotificationsService._();

  /// Phải trùng `default_notification_channel_id` trong AndroidManifest và `channelId` trong Cloud Functions.
  static const channelId = 'channel_id';

  static const _channel = AndroidNotificationChannel(
    channelId,
    'Thông báo công việc',
    description: 'Báo lỗi mới, giao việc và cập nhật xử lý',
    importance: Importance.max,
  );

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _nextId = 0;

  /// [onTap] nhận `payload` khi người dùng bấm vào thông báo đang hiển thị.
  Future<void> init({required void Function(String? payload) onTap}) async {
    if (_initialized) return;

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notification'),
        // Quyền iOS do FirebaseMessaging.requestPermission xin, tránh hỏi hai lần.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) => onTap(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> show({String? title, String? body, String? payload}) async {
    if (!_initialized) return;
    await _plugin.show(
      _nextId++,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_stat_notification',
          color: const Color(0xFF00408C),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
