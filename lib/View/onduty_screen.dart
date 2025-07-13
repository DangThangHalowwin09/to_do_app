import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DutyScreen extends StatefulWidget {
  const DutyScreen({super.key});

  @override
  State<DutyScreen> createState() => _DutyScreenState();
}

class _DutyScreenState extends State<DutyScreen> {
  int getCurrentDutyId() {
    final DateTime startDuty = DateTime(2025, 7, 5, 8, 0, 0);
    final DateTime now = DateTime.now();
    final duration = now.difference(startDuty);
    final daysPassed = duration.inHours ~/ 24;
    return daysPassed % 13;
  }

  int getDutyIdByDate(DateTime date) {
    final DateTime startDuty = DateTime(2025, 7, 5, 8);
    final daysPassed = date.difference(startDuty).inDays;
    return (daysPassed >= 0) ? daysPassed % 13 + 1 : -1;
  }

  Future<Map<String, dynamic>?> getUserInfoById(int id) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('idDuty', isEqualTo: id)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  String _formatDateVN(DateTime date) {
    const weekdays = [
      'Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư',
      'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'
    ];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday, ${date.day}/${date.month}/${date.year}';
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025, 7, 5),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      final id = getDutyIdByDate(picked);
      final user = await getUserInfoById(id);
      if (user != null) {
        final name = user['name'] ?? 'Không có tên';
        final phone = user['phone'] ?? 'Chưa có số';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Kết quả tra cứu'),
            content: Text('Từ 08:00, ${_formatDateVN(picked)} \nNgười trực: $name\nSố điện thoại: $phone'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    }
  }

  void _showUserMonthPicker() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final users = usersSnapshot.docs.map((doc) => doc.data()).toList();

    Map<String, dynamic>? selectedUser;
    int selectedMonth = DateTime.now().month;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chọn người và tháng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Map<String, dynamic>>(
                hint: const Text('Chọn người'),
                value: selectedUser,
                isExpanded: true,
                items: users.map((user) {
                  return DropdownMenuItem(
                    value: user,
                    child: Text(user['name'] ?? 'Không tên'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedUser = value),
              ),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: selectedMonth,
                isExpanded: true,
                items: List.generate(12, (index) => index + 1).map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text('Tháng $month'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedMonth = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedUser != null) {
                  final int id = selectedUser!['idDuty'];
                  final now = DateTime.now();
                  final year = now.year;
                  List<String> dutyDays = [];

                  for (int day = 1; day <= 31; day++) {
                    final date = DateTime(year, selectedMonth, day);
                    if (date.month != selectedMonth) break;
                    if (getDutyIdByDate(date) == id) {
                      dutyDays.add('${date.day}/${date.month}');
                    }
                  }

                  final dutyText = dutyDays.isEmpty
                      ? 'Không có lịch trực trong tháng này.'
                      : 'Các ngày trực trong tháng: ${dutyDays.join(', ')}';

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Kết quả tra cứu'),
                      content: Text(dutyText),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Xem'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int idDuty = getCurrentDutyId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo trực'),
        centerTitle: true,
        actions: [


        ],
      ),
      body: Column(
          //mainAxisAlignment: MainAxisAlignment.top,
          children: [
            const SizedBox(height: 25),

      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _showDatePicker,
            child: const Text('Tra lịch trực'),
          ),
          /*ElevatedButton(
            onPressed: _showUserMonthPicker,
            child: const Text('Lịch theo người'),
          ),*/
        ],
      ),
    ),
    const SizedBox(height: 20),

      FutureBuilder<Map<String, dynamic>?>(

        future: getUserInfoById(idDuty),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Không tìm thấy nhân viên'));
          }

          final userName = data['name'] ?? 'Không có tên';
          final phoneRaw = data['phone'];
          final phoneNumber = (phoneRaw == null || phoneRaw.toString().trim().isEmpty)
              ? 'Chưa có số'
              : phoneRaw.toString();

          return Center(

            child: Card(
              margin: const EdgeInsets.all(24),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 80, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      'Nhân viên trực hôm nay:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      phoneNumber,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),

                   /* const SizedBox(height: 2),
                    Text(
                      '(ID: $idDuty)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),*/
                    const SizedBox(height: 5),
                    Text(
                      'Từ 08:00 ${_formatDateVN(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Đến 08:00 ${_formatDateVN(DateTime.now().add(Duration(days: 1)))}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      ]
    )
    );
  }
}
