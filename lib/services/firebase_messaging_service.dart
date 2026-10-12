import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/constants/app_routes.dart';
import '../core/navigation.dart';
import '../core/utils/app_logger.dart';
import 'auth_service.dart';
import 'local_notifications_service.dart';

/// Nhận push notification (FCM) trên Android/iOS.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await LocalNotificationsService.instance.init();

    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    AppLog.d('Quyền thông báo: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openScreenFor);
    _messaging.onTokenRefresh.listen((_) => AuthService().saveFcmToken());
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    LocalNotificationsService.instance.show(
      title: notification.title,
      body: notification.body,
      payload: message.data.toString(),
    );
  }

  /// Bấm vào thông báo khi app đang chạy nền → mở màn hình tương ứng.
  void _openScreenFor(RemoteMessage message) {
    final type = message.data[PushDataKeys.type];
    final id = message.data[PushDataKeys.id];
    if (id == null) return;

    final route = switch (type) {
      PushDataKeys.taskType => AppRoutes.task,
      PushDataKeys.errorType => AppRoutes.error,
      _ => null,
    };
    if (route != null) {
      navigatorKey.currentState?.pushNamed(route, arguments: {PushDataKeys.id: id});
    }
  }
}

/// Phải là hàm top-level để chạy được khi app đã bị tắt hẳn.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  AppLog.d('Background message: ${message.data}');
}
