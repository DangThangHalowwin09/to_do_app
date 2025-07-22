import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initFCM() async {
  final messaging = FirebaseMessaging.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('User chưa đăng nhập.');
    return;
  }

  try {
    // 1. Yêu cầu quyền
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Người dùng từ chối quyền thông báo');
      return;
    }

    // 2. Lấy token
    final token = await messaging.getToken();
    if (token == null) {
      print('Không lấy được token');
      return;
    }
    print('Token: $token');

    // 3. Lưu vào Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmToken': token,
    });

    // 4. Đăng ký lắng nghe foreground
    FirebaseMessaging.onMessage.listen((message) {
      print('Thông báo foreground: ${message.notification?.title}');
    });

    // 5. Chỉ đăng ký background handler nếu là Android
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(handleNotification);
    }

  } catch (e) {
    print('Lỗi khi init FCM: $e');
  }
}

// Phải đặt ngoài mọi class
Future<void> handleNotification(RemoteMessage message) async {
  print('===> Background notification: ${message.notification?.title}');
}
