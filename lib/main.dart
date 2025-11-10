import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/login_screen.dart';
import 'package:flutter_to_do_list/firebase_options.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_to_do_list/services/firebase_messaging_service.dart';
import 'package:flutter_to_do_list/services/local_notifications_service.dart';
import 'package:flutter_to_do_list/utils/helper.dart';
import 'View/error_screen.dart';
import 'View/roledirection_screen.dart';
import 'View/task_screen.dart';
import 'package:flutter/foundation.dart'; // Cho kIsWeb
import 'package:universal_platform/universal_platform.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void push_notification_setup() async{
  final localNotificationsService = LocalNotificationsService.instance();
  if (kIsWeb) {
    // Chỉ chạy code Firebase Messaging (FCM) cho Web
    //await setupFCMForWeb();
  } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
    // Chỉ khởi tạo LocalNotificationsService cho Mobile/Desktop
    try {
      await LocalNotificationsService.instance().init();
    } catch (e) {
      // BẮT LỖI TẠI ĐÂY để ngăn crash toàn bộ app
      print("Lỗi khi khởi tạo Local Notifications: $e");
    }
  }
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  if (kIsWeb) {
    // Chỉ chạy code Firebase Messaging (FCM) cho Web
    //await setupFCMForWeb();
  } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
    // Chỉ khởi tạo LocalNotificationsService cho Mobile/Desktop
    try {
      await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
    } catch (e) {
      // BẮT LỖI TẠI ĐÂY để ngăn crash toàn bộ app
      print("Lỗi khi khởi tạo firebaseMassagingService: $e");
    }
  }

}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  push_notification_setup();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (!kIsWeb) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // Lấy token của thiết bị
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Lắng nghe khi app foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận thông báo: ${message.notification?.title}');
    });
  }
  await StatisticHelper.recordVisit(StatisticHelper.getPlatform());

  runApp(
    Portal( // 👈 bọc Portal ở đây
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
      routes: {
        //'/login': (context) => const LoginScreen(),
        //'/roleRedirect': (context) => const RoleRedirectScreen(),
        PushNotificationHelper.TaskScreenRoute: (context) => const TaskScreen(),
        PushNotificationHelper.ErrorScreenRoute: (context) => const ErrorScreen(),
      },
        home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const RoleRedirectScreen();
        // đã đăng nhập
        }
        else {
          return const LoginScreen(); // chưa đăng nhập
        }
      },
      ),
    );
  }

}

