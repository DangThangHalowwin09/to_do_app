import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_routes.dart';
import '../core/navigation.dart';
import '../core/utils/app_logger.dart';
import 'local_notifications_service.dart';
import 'user_session.dart';

/// Nhận thông báo đẩy (FCM) trên Android, iOS và Web; mở đúng màn hình khi bấm.
///
/// Thiết bị được đăng ký ở `users/{uid}/devices/{token}` (mỗi máy/trình duyệt một bản ghi).
/// Việc GỬI thông báo do Cloud Functions (thư mục `functions/`) đảm nhiệm.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Web chỉ nhận push khi đã cấu hình khoá VAPID lúc build.
  static bool get isSupported => !kIsWeb || AppConfig.webVapidKey.isNotEmpty;

  static bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  String? _pendingRoute;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || !isSupported) return;
    _initialized = true;

    if (_isAndroid) {
      await LocalNotificationsService.instance.init(onTap: _onLocalNotificationTap);
    }

    if (!kIsWeb) {
      // Trình duyệt chỉ cho xin quyền sau thao tác của người dùng → web xin ở màn hình Thông báo.
      final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
      AppLog.d('Quyền thông báo: ${settings.authorizationStatus}');
      // iOS mặc định ẩn thông báo khi app đang mở; bật lại để hiện banner.
      await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(routeFor(m.data)));
    _messaging.onTokenRefresh.listen((_) => registerDevice());

    // App đang tắt hẳn, người dùng bấm vào thông báo để mở app.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _pendingRoute = routeFor(initial.data);
  }

  /// Trạng thái quyền thông báo hiện tại của thiết bị / trình duyệt này.
  Future<AuthorizationStatus> permissionStatus() async {
    if (!isSupported) return AuthorizationStatus.notDetermined;
    return (await _messaging.getNotificationSettings()).authorizationStatus;
  }

  /// Xin quyền (gọi từ một nút bấm, bắt buộc trên web) rồi đăng ký thiết bị.
  Future<AuthorizationStatus> requestPermissionAndRegister() async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await registerDevice();
    }
    return settings.authorizationStatus;
  }

  /// Lưu token của thiết bị này vào hồ sơ người đang đăng nhập.
  Future<void> registerDevice() async {
    final uid = UserSession.instance.uid;
    if (uid == null || !isSupported) return;
    try {
      if (kIsWeb) {
        final status = await permissionStatus();
        if (status != AuthorizationStatus.authorized) return;
      }
      final token = await _token();
      if (token == null) return;
      await _devices(uid).doc(token).set({
        'token': token,
        'platform': _platformName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLog.e('Không đăng ký được thiết bị nhận thông báo', e);
    }
  }

  /// Gỡ thiết bị này khỏi tài khoản (khi đăng xuất) để không nhận thông báo của người khác.
  Future<void> unregisterDevice() async {
    final uid = UserSession.instance.uid;
    if (uid == null || !isSupported) return;
    try {
      final token = await _token();
      if (token != null) await _devices(uid).doc(token).delete();
    } catch (e) {
      AppLog.e('Không gỡ được thiết bị nhận thông báo', e);
    }
  }

  /// Gọi từ màn hình chính sau đăng nhập để mở màn hình tương ứng với thông báo đã bấm.
  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  /// Màn hình ứng với loại thông báo (`data.type`).
  static String? routeFor(Map<String, dynamic> data) {
    switch (data[PushDataKeys.type]) {
      case PushDataKeys.taskType:
        return AppRoutes.task;
      case PushDataKeys.errorType:
      case PushDataKeys.ratingType:
        return AppRoutes.error;
      default:
        return null;
    }
  }

  Future<String?> _token() => kIsWeb ? _messaging.getToken(vapidKey: AppConfig.webVapidKey) : _messaging.getToken();

  CollectionReference<Map<String, dynamic>> _devices(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('devices');

  String get _platformName {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    if (_isAndroid) {
      LocalNotificationsService.instance.show(
        title: notification.title,
        body: notification.body,
        payload: jsonEncode(message.data),
      );
      return;
    }
    if (kIsWeb) {
      // Trình duyệt không tự hiện thông báo khi trang đang mở → hiện banner trong app.
      final route = routeFor(message.data);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text([notification.title, notification.body].whereType<String>().join('\n')),
          action: route == null ? null : SnackBarAction(label: 'Xem', onPressed: () => _open(route)),
        ),
      );
    }
    // iOS: hệ điều hành tự hiện banner nhờ setForegroundNotificationPresentationOptions.
  }

  void _onLocalNotificationTap(String? payload) {
    if (payload == null) return;
    try {
      _open(routeFor(Map<String, dynamic>.from(jsonDecode(payload) as Map)));
    } catch (e) {
      AppLog.e('Payload thông báo không hợp lệ', e);
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
