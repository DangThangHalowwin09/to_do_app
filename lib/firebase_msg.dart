import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initFCM() async {
  if (kIsWeb) {
    print('👉 Web: initFCM chỉ nên gọi sau thao tác người dùng (bấm nút)');
    return;
  }

  final messaging = FirebaseMessaging.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('User chưa đăng nhập.');
    return;
  }

  try {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Người dùng từ chối quyền thông báo');
      return;
    }

    final token = await messaging.getToken();
    print('Token: $token');

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmToken': token,
    });

    FirebaseMessaging.onMessage.listen((message) {
      print('Thông báo foreground: ${message.notification?.title}');
    });

    if (!kIsWeb && Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(handleNotification);
    }

  } catch (e) {
    print('Lỗi khi init FCM: $e');
  }
}

Future<void> handleNotification(RemoteMessage message) async {
  print('===> Background notification: ${message.notification?.title}');
}
