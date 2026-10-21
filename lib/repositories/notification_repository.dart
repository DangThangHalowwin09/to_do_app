import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository._();

  static CollectionReference<Map<String, dynamic>> _inbox(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications');

  static Stream<List<AppNotification>> watch(String uid, {int limit = 100}) => _inbox(uid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(AppNotification.fromDoc).toList());

  static Stream<int> watchUnreadCount(String uid) =>
      _inbox(uid).where('read', isEqualTo: false).snapshots().map((s) => s.size);

  static Future<void> markRead(String uid, String id) => _inbox(uid).doc(id).update({'read': true});

  static Future<void> markAllRead(String uid) async {
    final unread = await _inbox(uid).where('read', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
