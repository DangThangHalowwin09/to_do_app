import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen ({super.key});
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  String? currentUserRole;
  String? currentUserId;

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
        });
      }
    }
  }

  Future<void> _showTaskDialog({DocumentSnapshot? task}) async {
    final titleController = TextEditingController(text: task?['title'] ?? '');
    final descriptionController = TextEditingController(text: task?['description'] ?? '');
    DateTime? startTime = task?['startTime']?.toDate();
    DateTime? endTime = task?['endTime']?.toDate();
    String? assignedTo;

    if (task != null) assignedTo = task['assignedTo'];

    final usersSnapshot = await users
        .where('role', whereIn: ['Nhân viên phần mềm', 'Nhân viên phần cứng'])
        .get();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task == null ? 'Thêm Task' : 'Sửa Task'),
        content: SingleChildScrollView(
          child: Column(
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
                title: Text(startTime == null ? 'Chọn thời gian bắt đầu' : 'Bắt đầu: ${startTime.toString()}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startTime ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => startTime = picked);
                },
              ),
              ListTile(
                title: Text(endTime == null ? 'Chọn thời gian kết thúc' : 'Kết thúc: ${endTime.toString()}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endTime ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => endTime = picked);
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          ElevatedButton(
            child: Text('Lưu'),
            onPressed: () async {
              final data = {
                'title': titleController.text,
                'description': descriptionController.text,
                'startTime': Timestamp.fromDate(startTime ?? DateTime.now()),
                'endTime': Timestamp.fromDate(endTime ?? DateTime.now()),
                'assignedTo': assignedTo,
                'status': task?['status'] ?? 'pending',
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
  }

  Future<void> _markTaskDone(String taskId) async {
    await tasks.doc(taskId).update({'status': 'done'});
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserRole == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Task')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Task')),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasks.orderBy('startTime').snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final task = docs[i];
              final isAssignedToMe = task['assignedTo'] == currentUserId;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Chi tiết: ${task['description']}"),
                      Text("Bắt đầu: ${task['startTime'].toDate()}"),
                      Text("Kết thúc: ${task['endTime'].toDate()}"),
                      Text("Trạng thái: ${task['status']}"),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      if (currentUserRole == "Admin")
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showTaskDialog(task: task),
                        ),
                      if ((currentUserRole == "Nhân viên phần mềm" || currentUserRole == "Nhân viên phần cứng") && isAssignedToMe)
                        IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _markTaskDone(task.id),
                        ),
                    ],
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
