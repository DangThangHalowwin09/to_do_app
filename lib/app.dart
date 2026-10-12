import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/navigation.dart';
import 'screens/auth/finish_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/errors/error_screen.dart';
import 'screens/general_information_screen.dart';
import 'screens/role_redirect_screen.dart';
import 'screens/tasks/task_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UBNA Manager',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.updateProfile: (_) => const FinishProfileScreen(),
        AppRoutes.task: (_) => const TaskScreen(),
        AppRoutes.error: (_) => const ErrorScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const RoleRedirectScreen() : const GeneralInformationScreen();
        },
      ),
    );
  }
}
