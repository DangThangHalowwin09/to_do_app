import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task_item.dart';
import '../../repositories/task_repository.dart';

/// Hộp thoại thêm / sửa nhiệm vụ (chỉ admin).
class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({super.key, required this.staffNames, this.task});

  /// `uid → tên` của những người có thể được giao việc.
  final Map<String, String> staffNames;
  final TaskItem? task;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _dateFormat = DateFormat('HH:mm, dd-MM-yyyy');
  late final _titleController = TextEditingController(text: widget.task?.title);
  late final _descriptionController = TextEditingController(text: widget.task?.description);
  late DateTime? _deadline = widget.task?.endTime;
  late String? _assignedTo =
      widget.staffNames.containsKey(widget.task?.assignedTo) ? widget.task!.assignedTo : null;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _warn(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) return _warn('Vui lòng nhập tiêu đề');
    if (description.isEmpty) return _warn('Vui lòng nhập mô tả');
    if (_deadline == null) return _warn('Vui lòng chọn Deadline');
    if (_assignedTo == null) return _warn('Vui lòng chọn người nhận');

    setState(() => _saving = true);
    try {
      await TaskRepository.save(
        taskId: widget.task?.id,
        title: title,
        description: description,
        deadline: _deadline!,
        assignedTo: _assignedTo!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _warn('Lưu nhiệm vụ thất bại, vui lòng thử lại');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Thêm nhiệm vụ' : 'Sửa nhiệm vụ'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Cụ thể')),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_deadline == null ? 'Chọn Deadline' : 'Deadline: ${_dateFormat.format(_deadline!)}'),
              trailing: const Icon(Icons.event),
              onTap: _pickDeadline,
            ),
            DropdownButtonFormField<String>(
              initialValue: _assignedTo,
              decoration: const InputDecoration(labelText: 'Giao cho'),
              items: [
                for (final entry in widget.staffNames.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) => setState(() => _assignedTo = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}
