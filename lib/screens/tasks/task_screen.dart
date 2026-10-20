import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task_item.dart';
import '../../core/constants/app_colors.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/status_chip.dart';
import '../../services/user_session.dart';
import 'task_form_dialog.dart';

/// Danh sách nhiệm vụ phòng IT. Admin: thêm/sửa. Người khác: xem chi tiết và đánh dấu việc của mình.
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  static final _listDate = DateFormat('HH:mm, dd/MM/yyyy');
  static final _detailDate = DateFormat('dd/MM/yyyy');

  final _session = UserSession.instance;
  late final Future<Map<String, String>> _staffNames = TaskRepository.itStaffNames();

  String _dateText(DateTime? date, DateFormat format) => date == null ? 'Chưa có' : format.format(date);

  Future<void> _openForm([TaskItem? task]) async {
    final names = await _staffNames;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => TaskFormDialog(staffNames: names, task: task),
    );
  }

  Future<void> _openDetail(TaskItem task) async {
    final names = await _staffNames;
    if (!mounted) return;
    final isMine = task.assignedTo == _session.uid;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chi tiết nhiệm vụ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tiêu đề:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.title),
              const SizedBox(height: 8),
              const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.description),
              const SizedBox(height: 8),
              Text('Ngày giao: ${_dateText(task.startTime, _detailDate)}'),
              Text('Deadline: ${_dateText(task.endTime, _detailDate)}'),
              const SizedBox(height: 8),
              Text('Người được giao: ${names[task.assignedTo] ?? 'Không xác định'}'),
              Text('Trạng thái: ${task.status}'),
              if (task.completedAt != null) Text('Hoàn thành: ${_detailDate.format(task.completedAt!)}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
          if (isMine && !task.isDone)
            FilledButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Đánh dấu đã thực hiện'),
              onPressed: () async {
                await TaskRepository.markDone(task.id);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _session.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Nhiệm vụ')),
      body: FutureBuilder<Map<String, String>>(
        future: _staffNames,
        builder: (context, namesSnapshot) {
          final names = namesSnapshot.data ?? const <String, String>{};

          return StreamBuilder<List<TaskItem>>(
            stream: TaskRepository.watchAll(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Không tải được danh sách nhiệm vụ'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final tasks = snapshot.data!;
              if (tasks.isEmpty) return const Center(child: Text('Chưa có nhiệm vụ nào'));

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final overdue = !task.isDone && task.endTime != null && task.endTime!.isBefore(DateTime.now());
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      onTap: () => isAdmin ? _openForm(task) : _openDetail(task),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            StatusChip(task.isDone ? WorkStatus.done : WorkStatus.pending),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.description),
                          const SizedBox(height: 4),
                          Text('Người được giao: ${names[task.assignedTo] ?? '...'}'),
                          Text('Giao vào: ${_dateText(task.startTime, _listDate)}'),
                          Text(
                            overdue
                                ? 'Quá hạn: ${_dateText(task.endTime, _listDate)}'
                                : 'Deadline: ${_dateText(task.endTime, _listDate)}',
                            style: overdue
                                ? const TextStyle(color: AppColors.urgent, fontWeight: FontWeight.w700)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              tooltip: 'Thêm nhiệm vụ',
              onPressed: _openForm,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
