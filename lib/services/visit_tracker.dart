import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/app_logger.dart';

/// Ghi lượt truy cập theo tháng vào `visits/{yyyy-MM}`.
class VisitTracker {
  VisitTracker._();

  static String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'Ios';
      default:
        return 'Khác';
    }
  }

  static Future<void> recordVisit() async {
    try {
      final now = DateTime.now();
      final docId = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      await FirebaseFirestore.instance.collection('visits').doc(docId).set({
        'platform_$platformName': FieldValue.increment(1),
        'todayVisits': FieldValue.increment(1),
        'weekVisits': FieldValue.increment(1),
        'monthVisits': FieldValue.increment(1),
        'lastUpdate': now,
      }, SetOptions(merge: true));
    } catch (e, st) {
      AppLog.e('recordVisit thất bại', e, st);
    }
  }
}
