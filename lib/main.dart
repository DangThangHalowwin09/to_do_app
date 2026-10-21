import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'app.dart';
import 'core/utils/app_logger.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'services/onboarding_store.dart';
import 'services/visit_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  unawaited(VisitTracker.recordVisit());
  await _initPushNotifications();

  final showOnboarding = !await OnboardingStore.hasSeen();
  runApp(Portal(child: MyApp(showOnboarding: showOnboarding)));
}

/// Thông báo đẩy cho Android, iOS và Web; lỗi ở đây không được làm app không mở được.
Future<void> _initPushNotifications() async {
  final supported = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (!supported) return;

  try {
    await FirebaseMessagingService.instance.init();
  } catch (e) {
    AppLog.e('Không khởi tạo được push notification', e);
  }
}
