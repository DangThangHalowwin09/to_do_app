import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen ({super.key});
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final CollectionReference tasks = FirebaseFirestore.instance.collection(
      'tasks');
  final CollectionReference users = FirebaseFirestore.instance.collection(
      'users');

  String? currentUserRole;
  String? currentUserId;

  String? currentUserName;
  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
  }

  Future<void> getCurrentUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await users.doc(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          currentUserId = user.uid;
          currentUserRole = snapshot['role'];
          currentUserName = snapshot['name'];
        });
      }
    }
  }

  Future<void> _showTaskDialog({DocumentSnapshot? task}) async {
    final titleController = TextEditingController(text: task?['title'] ?? '');
    final descriptionController = TextEditingController(
        text: task?['description'] ?? '');
    DateTime? startTime = task?['startTime']?.toDate();
    DateTime? endTime = task?['endTime']?.toDate();
    String? assignedTo;

    if (task != null) assignedTo = task['assignedTo'];

    final usersSnapshot = await users
        .where('role', whereIn: ['Tổ phần mềm', 'Tổ phần cứng'])
        .get();
    await showDialog(
      context: context,
      builder: (_) {
        final dateFormat = DateFormat('dd/MM/yyyy'); // định dạng ngày

        return StatefulBuilder(
          builder: (context, setState) =>
              AlertDialog(
                title: Text(task == null ? 'Thêm Task' : 'Sửa Task'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Tiêu đề'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Cụ thể'),
                      ),
                      ListTile(
                        title: Text(
                          startTime == null
                              ? 'Chọn thời gian bắt đầu'
                              : 'Bắt đầu: ${dateFormat.format(startTime!)}',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startTime ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => startTime = picked);
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                          endTime == null
                              ? 'Chọn thời gian kết thúc'
                              : 'Kết thúc: ${dateFormat.format(endTime!)}',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endTime ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => endTime = picked);
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: assignedTo,
                        items: usersSnapshot.docs.map((doc) {
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(doc['name'] ?? 'Không tên'),
                          );
                        }).toList(),
                        onChanged: (value) => assignedTo = value,
                        decoration: InputDecoration(labelText: 'Giao cho'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy'),
                  ),
                  ElevatedButton(
                    child: Text('Lưu'),
                    onPressed: () async {
                      final data = {
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'startTime': Timestamp.fromDate(
                            startTime ?? DateTime.now()),
                        'endTime': Timestamp.fromDate(
                            endTime ?? DateTime.now()),
                        'assignedTo': assignedTo,
                        'status': task?['status'] ?? 'pending',
                        'completedAt': task?['completedAt'], // <--- thêm dòng này
                      };

                      if (task == null) {
                        await tasks.add(data);
                      } else {
                        await tasks.doc(task.id).update(data);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
        );
      },
    );
  }

  Future<void> _showTaskDetailDialog(DocumentSnapshot task) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final startTime = task['startTime']?.toDate();
    final endTime = task['endTime']?.toDate();
    final completedAt = task['completedAt']?.toDate();
    final status = task['status'];
    final assignedToId = task['assignedTo'];

    // Lấy tên người được giao từ Firestore
    String assignedToName = 'Không xác định';
    if (assignedToId != null) {
      final assignedUser = await users.doc(assignedToId).get();
      assignedToName = assignedUser['name'] ?? 'Không tên';
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAssignedToMe = assignedToId == currentUserId;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Chi tiết Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📝 Tiêu đề:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(task['title']),
                SizedBox(height: 8),
                Text('📋 Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(task['description']),
                SizedBox(height: 8),
                Text('🕒 Bắt đầu: ${dateFormat.format(startTime)}'),
                Text('🕒 Kết thúc: ${dateFormat.format(endTime)}'),
                SizedBox(height: 8),
                Text('👤 Người được giao: $assignedToName'),
                Text('📌 Trạng thái: ${status ?? 'Chưa xác định'}'),
                if (completedAt != null)
                  Text('✅ Đã hoàn thành: ${dateFormat.format(completedAt)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => Navigator.pop(context),
            ),
            if (isAssignedToMe && status != 'done')
              ElevatedButton.icon(
                icon: Icon(Icons.check_circle),
                label: Text('Đánh dấu đã thực hiện'),
                onPressed: () async {
                  await tasks.doc(task.id).update({
                    'status': 'done',
                    'completedAt': Timestamp.now(),
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task')),
      body: currentUserRole == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: tasks.orderBy('startTime').snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final task = docs[i];
              //final isAssignedToMe = task['assignedTo'] == currentUserId;

              return InkWell(
                onTap: () async {
                  print("onTap called, role: $currentUserRole"); // test
                  if (currentUserRole == "Admin") {
                    await _showTaskDialog(task: task);
                  } else {
                    await _showTaskDetailDialog(task);
                  }
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${task['description']}"),
                        Text("Bắt đầu: ${DateFormat('dd/MM/yyyy').format(
                            task['startTime'].toDate())}"),
                        Text("Kết thúc: ${DateFormat('dd/MM/yyyy').format(
                            task['endTime'].toDate())}"),
                        Text("Trạng thái: ${task['status']}"),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: currentUserRole == "Admin"
          ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showTaskDialog(),
      )
          : null,
    );
  }
}
