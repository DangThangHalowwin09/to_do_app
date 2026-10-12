import 'package:cloud_firestore/cloud_firestore.dart';

/// Nhiệm vụ phòng IT do admin giao (collection `tasks`).
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    this.startTime,
    this.endTime,
    this.completedAt,
  });

  static const statusPending = 'pending';
  static const statusDone = 'done';

  final String id;
  final String title;
  final String description;
  final String? assignedTo;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? completedAt;

  bool get isDone => status == statusDone;

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime? date(String key) => (data[key] as Timestamp?)?.toDate();
    return TaskItem(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      assignedTo: data['assignedTo'] as String?,
      status: (data['status'] ?? statusPending) as String,
      startTime: date('startTime'),
      endTime: date('endTime'),
      completedAt: date('completedAt'),
    );
  }
}
