import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/login_screen.dart';
import 'package:flutter_to_do_list/firebase_options.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_to_do_list/data_postgreSQL/test_postgres.dart';
import 'View/roledirection_screen.dart';
import 'firebase_msg.dart'; //

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initFCM();

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
       /* if (snapshot.hasData) {

          return const RoleRedirectScreen();
        // đã đăng nhập
        }
        else {
          return const LoginScreen(); // chưa đăng nhập
        }*/
          return const PatientsScreen();
      },
      ),
    );
  }
}
