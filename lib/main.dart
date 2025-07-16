import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/login_screen.dart';
import 'package:flutter_to_do_list/firebase_options.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'View/all_welcome_screens.dart';
import 'View/signup_screen.dart';
import 'View/roledirection_screen.dart'; //

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /*FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  // Lưu FCM token khi vào app
  final token = await messaging.getToken();
  final userId = 'CURRENT_USER_ID'; // thay bằng user thực tế
  if (token != null) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }*/

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
        debugShowCheckedModeBanner: false,
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
