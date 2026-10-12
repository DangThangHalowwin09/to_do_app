import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/constants/app_routes.dart';
import '../core/navigation.dart';
import '../core/utils/app_logger.dart';
import 'auth_service.dart';
import 'local_notifications_service.dart';
import 'user_session.dart';

/// Nhận push notification (FCM) trên Android/iOS và mở đúng màn hình khi bấm vào thông báo.
/// Việc GỬI thông báo do Cloud Functions (thư mục `functions/`) đảm nhiệm.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final _messaging = FirebaseMessaging.instance;

  /// Màn hình cần mở sau khi đăng nhập xong (khi bấm thông báo lúc app đang tắt hẳn).
  String? _pendingRoute;

  Future<void> init() async {
    await LocalNotificationsService.instance.init(onTap: _onLocalNotificationTap);

    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    AppLog.d('Quyền thông báo: ${settings.authorizationStatus}');

    // iOS mặc định ẩn thông báo khi app đang mở; bật lại để hiện banner.
    await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(_routeFor(m.data)));
    _messaging.onTokenRefresh.listen((_) => AuthService().saveFcmToken());

    // App đang tắt hẳn, người dùng bấm vào thông báo để mở app.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _pendingRoute = _routeFor(initial.data);
  }

  /// Gọi từ màn hình chính sau đăng nhập để mở màn hình tương ứng với thông báo đã bấm.
  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    // iOS tự hiện banner nhờ setForegroundNotificationPresentationOptions; Android cần tự hiện.
    LocalNotificationsService.instance.show(
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationTap(String? payload) {
    if (payload == null) return;
    try {
      _open(_routeFor(Map<String, dynamic>.from(jsonDecode(payload) as Map)));
    } catch (e) {
      AppLog.e('Payload thông báo không hợp lệ', e);
    }
  }

  String? _routeFor(Map<String, dynamic> data) {
    switch (data[PushDataKeys.type]) {
      case PushDataKeys.taskType:
        return AppRoutes.task;
      case PushDataKeys.errorType:
        return AppRoutes.error;
      default:
        return null;
    }
  }

  void _open(String? route) {
    if (route == null) return;
    final navigator = navigatorKey.currentState;
    // Chưa đăng nhập xong thì chờ màn hình chính xử lý (takePendingRoute).
    if (navigator == null || UserSession.instance.uid == null) {
      _pendingRoute = route;
      return;
    }
    navigator.pushNamed(route);
  }
}

/// Phải là hàm top-level để chạy được khi app đã bị tắt hẳn.
/// Thông báo có phần `notification` đã được hệ điều hành tự hiển thị, không cần xử lý thêm.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  AppLog.d('Background message: ${message.data}');
}
