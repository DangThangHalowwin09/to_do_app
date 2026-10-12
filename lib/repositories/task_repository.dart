import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_routes.dart';
import '../core/constants/user_role.dart';
import '../models/task_item.dart';
import '../services/push_notification_sender.dart';

class TaskRepository {
  TaskRepository._();

  static final _db = FirebaseFirestore.instance;
  static final _tasks = _db.collection('tasks');

  static Stream<List<TaskItem>> watchAll() =>
      _tasks.orderBy('startTime').snapshots().map((s) => s.docs.map(TaskItem.fromDoc).toList());

  /// Nhân viên IT có thể được giao việc: `uid → tên`.
  static Future<Map<String, String>> itStaffNames() async {
    final snapshot = await _db.collection('users').where('role', whereIn: UserRole.itLabels).get();
    return {for (final doc in snapshot.docs) doc.id: (doc.data()['name'] ?? 'Không tên') as String};
  }

  /// Tạo mới ([taskId] == null) hoặc cập nhật nhiệm vụ, rồi báo cho người được giao.
  static Future<void> save({
    String? taskId,
    required String title,
    required String description,
    required DateTime deadline,
    required String assignedTo,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'endTime': Timestamp.fromDate(deadline),
      'assignedTo': assignedTo,
    };

    final String id;
    if (taskId == null) {
      final ref = await _tasks.add({
        ...data,
        'startTime': Timestamp.now(),
        'status': TaskItem.statusPending,
        'completedAt': null,
      });
      id = ref.id;
    } else {
      id = taskId;
      await _tasks.doc(id).update(data);
    }

    await _notifyAssignee(assignedTo, title, id);
  }

  static Future<void> markDone(String taskId) => _tasks.doc(taskId).update({
        'status': TaskItem.statusDone,
        'completedAt': Timestamp.now(),
      });

  static Future<void> _notifyAssignee(String uid, String title, String taskId) async {
    final user = await _db.collection('users').doc(uid).get();
    final token = user.data()?['fcmToken'] as String?;
    if (token == null || token.isEmpty) return;

    await PushNotificationSender.send(
      targetToken: token,
      title: 'Trưởng phòng đã giao bạn nhiệm vụ mới!',
      body: title,
      data: {PushDataKeys.type: PushDataKeys.taskType, PushDataKeys.id: taskId},
    );
  }
}
