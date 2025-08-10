import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
Future<void> initFCM() async {
  // Đảm bảo Firebase đã init xong
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
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
    if (token == null) {
      print('Không lấy được token');
      return;
    }

    print('Token: $token');

    // Nếu muốn lưu Firestore, đảm bảo internet + user tồn tại
    // await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
    //   'fcmToken': token,
    // });

    FirebaseMessaging.onMessage.listen((message) {
      print('Thông báo foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(handleNotification);

  } catch (e) {
    print('Lỗi khi init FCM: $e');
  }
}


// Phải đặt ngoài mọi class
Future<void> handleNotification(RemoteMessage message) async {
  print('===> Background notification: ${message.notification?.title}');
}
