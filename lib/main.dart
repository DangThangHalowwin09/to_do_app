import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'app.dart';
import 'core/utils/app_logger.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'services/visit_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  unawaited(VisitTracker.recordVisit());
  await _initPushNotifications();

  runApp(const Portal(child: MyApp()));
}

/// Push notification chỉ hỗ trợ app Android/iOS; lỗi ở đây không được làm app không mở được.
Future<void> _initPushNotifications() async {
  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  if (!isMobile) return;

  try {
    await FirebaseMessagingService.instance.init();
  } catch (e) {
    AppLog.e('Không khởi tạo được push notification', e);
  }
}
