import 'package:flutter/material.dart';

import '../core/utils/duty_schedule.dart';
import '../repositories/duty_repository.dart';

/// Tra cứu người trực CNTT hôm nay, theo ngày, hoặc theo từng người.
class DutyScreen extends StatefulWidget {
  const DutyScreen({super.key});

  @override
  State<DutyScreen> createState() => _DutyScreenState();
}

class _DutyScreenState extends State<DutyScreen> {
  late final Future<Map<int, DutyPerson>> _roster = DutyRepository.loadRoster();

  Future<void> _showMessage(String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  String _describe(DutyPerson? person) =>
      person == null ? 'Chưa có dữ liệu' : '${person.name}\nSố điện thoại: ${person.phone.isEmpty ? 'Chưa có số' : person.phone}';

  Future<void> _lookupByDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DutySchedule.firstDay,
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null) return;

    final roster = await _roster;
    final id = DutySchedule.idOnDate(picked);
    if (!mounted) return;
    if (id == null) return _showMessage('Kết quả tra cứu', 'Chưa có lịch trực cho ngày này.');

    final date = DutySchedule.formatDate(picked);
    await _showMessage(
      'Kết quả tra cứu',
      'Trước 08:00, $date\nNgười trực: ${_describe(roster[DutySchedule.previousId(id)])}\n\n'
          'Sau 08:00, $date\nNgười trực: ${_describe(roster[id])}',
    );
  }

  Future<void> _lookupByPerson() async {
    final roster = await _roster;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _PersonMonthDialog(roster: roster),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayId = DutySchedule.idOnDate(today);

    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo trực'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton(onPressed: _lookupByDate, child: const Text('Tra lịch trực')),
                  FilledButton(onPressed: _lookupByPerson, child: const Text('Lịch theo người')),
                ],
              ),
            ),
            FutureBuilder<Map<int, DutyPerson>>(
              future: _roster,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator());
                }
                if (snapshot.hasError || todayId == null) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Không tải được lịch trực, vui lòng thử lại sau'),
                  );
                }
                final roster = snapshot.data!;
                return Column(
                  children: [
                    _DutyCard(
                      icon: Icons.light_mode,
                      iconColor: Colors.deepPurple,
                      heading: 'Nhân viên trực ca sáng:',
                      person: roster[DutySchedule.previousId(todayId)],
                      from: 'Từ 00:00 ${DutySchedule.formatDate(today)}',
                      to: 'Đến 08:00 ${DutySchedule.formatDate(today)}',
                      large: false,
                    ),
                    _DutyCard(
                      icon: Icons.nightlight_round,
                      iconColor: Colors.blue,
                      heading: 'Nhân viên trực hôm nay:',
                      person: roster[todayId],
                      from: 'Từ 08:00 ${DutySchedule.formatDate(today)}',
                      to: 'Đến 08:00 ${DutySchedule.formatDate(today.add(const Duration(days: 1)))}',
                      large: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DutyCard extends StatelessWidget {
  const _DutyCard({
    required this.icon,
    required this.iconColor,
    required this.heading,
    required this.person,
    required this.from,
    required this.to,
    required this.large,
  });

  final IconData icon;
  final Color iconColor;
  final String heading;
  final DutyPerson? person;
  final String from;
  final String to;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final phone = person == null || person!.phone.isEmpty ? 'Chưa có số' : person!.phone;

    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: large ? 80 : 50, color: iconColor),
            const SizedBox(height: 10),
            Text(heading, style: large ? theme.titleLarge : theme.titleMedium),
            const SizedBox(height: 5),
            Text(
              person?.name ?? 'Không tìm thấy nhân viên',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: large ? 27 : 20, fontWeight: FontWeight.bold),
            ),
            if (person != null)
              Text(phone, style: TextStyle(fontSize: large ? 21 : 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text(from, style: theme.bodySmall),
            Text(to, style: theme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PersonMonthDialog extends StatefulWidget {
  const _PersonMonthDialog({required this.roster});

  final Map<int, DutyPerson> roster;

  @override
  State<_PersonMonthDialog> createState() => _PersonMonthDialogState();
}

class _PersonMonthDialogState extends State<_PersonMonthDialog> {
  int? _selectedId;
  int _month = DateTime.now().month;
  String? _result;

  void _lookup() {
    final id = _selectedId;
    if (id == null) return;
    final days = DutySchedule.daysOfMonth(id: id, year: DateTime.now().year, month: _month);
    final name = widget.roster[id]!.name;
    setState(() {
      _result = days.isEmpty
          ? 'Không có lịch trực trong tháng $_month cho $name.'
          : 'Các ngày trực trong tháng $_month của $name: ${days.map((d) => '${d.day}/${d.month}').join(', ')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ids = widget.roster.keys.toList()..sort();

    return AlertDialog(
      title: const Text('Chọn người và tháng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _selectedId,
            isExpanded: true,
            hint: const Text('Chọn người'),
            items: [for (final id in ids) DropdownMenuItem(value: id, child: Text(widget.roster[id]!.name))],
            onChanged: (value) => setState(() {
              _selectedId = value;
              _result = null;
            }),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _month,
            isExpanded: true,
            items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text('Tháng $m'))],
            onChanged: (value) => setState(() {
              _month = value!;
              _result = null;
            }),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Text(_result!),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        FilledButton(onPressed: _selectedId == null ? null : _lookup, child: const Text('Xem')),
      ],
    );
  }
}
