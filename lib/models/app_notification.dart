import 'package:cloud_firestore/cloud_firestore.dart';

/// Một thông báo trong hộp thư của người dùng (`users/{uid}/notifications/{id}`).
/// Cloud Functions ghi vào đây đồng thời với việc gửi push, nên người dùng không bỏ lỡ
/// thông báo kể cả khi tắt quyền thông báo hoặc mở bằng trình duyệt.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.refId,
    required this.read,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;

  /// `error` | `task` | `rating` — quyết định màn hình mở ra khi bấm.
  final String type;
  final String refId;
  final bool read;
  final DateTime? createdAt;

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      body: (d['body'] ?? '') as String,
      type: (d['type'] ?? '') as String,
      refId: (d['refId'] ?? '') as String,
      read: d['read'] == true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
