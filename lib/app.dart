import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/navigation.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/finish_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/errors/error_screen.dart';
import 'screens/general_information_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/role_redirect_screen.dart';
import 'screens/tasks/task_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.showOnboarding = false});

  /// Lần mở đầu tiên trên thiết bị: hiện giới thiệu trước trang chủ.
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UBNA Manager',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
          if (snapshot.hasData) return const RoleRedirectScreen();
          return showOnboarding ? const _FirstRunGate() : const GeneralInformationScreen();
        },
      ),
    );
  }
}

/// Hiện giới thiệu một lần, sau đó chuyển sang trang chủ cho khách.
class _FirstRunGate extends StatefulWidget {
  const _FirstRunGate();

  @override
  State<_FirstRunGate> createState() => _FirstRunGateState();
}

class _FirstRunGateState extends State<_FirstRunGate> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return _done
        ? const GeneralInformationScreen()
        : OnboardingScreen(onFinished: () => setState(() => _done = true));
  }
}
