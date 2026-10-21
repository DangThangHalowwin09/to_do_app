import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/user_role.dart';
import '../models/task_item.dart';
import '../services/user_session.dart';

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

    // Thông báo cho người được giao do Cloud Function `onTaskCreated/onTaskUpdated` gửi.
    if (taskId == null) {
      await _tasks.add({
        ...data,
        'startTime': Timestamp.now(),
        'status': TaskItem.statusPending,
        'completedAt': null,
        'createdBy': UserSession.instance.uid,
      });
    } else {
      // Đổi hạn thì cho phép nhắc lại từ đầu.
      await _tasks.doc(taskId).update({...data, 'reminders': FieldValue.delete()});
    }
  }

  static Future<void> markDone(String taskId) => _tasks.doc(taskId).update({
        'status': TaskItem.statusDone,
        'completedAt': Timestamp.now(),
      });
}
