import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách thành viên')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;
              final name = user['name'] ?? 'Chưa có tên';

              return ListTile(
                title: Text(name),
                trailing: const Icon(Icons.info_outline),
                onTap: () => _showUserDetailsDialog(context, user, docId),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context, Map<String, dynamic> user, String docId) {
    final role = user['role'] ?? '';
    final areas = user['areas'] ?? [];
    final email = user['email'];
    final number = user['number'];
    final bio = user['bio'];

    final name = user['name'] ?? 'Không rõ';
    final isHardwareTeam = role == 'Tổ phần cứng';
    final TextEditingController _roleController = TextEditingController(text: role);
    List<String> _selectedAreas = List<String>.from(areas);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(name),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (email != null) Text('Email: $email'),
                    if (number != null) Text('SĐT: $number'),
                    if (bio != null) Text('Giới thiệu: $bio'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _roleController,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                    ),
                    if (_roleController.text == 'Tổ phần cứng')
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('areas').get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const CircularProgressIndicator();
                          final allAreas = snapshot.data!.docs.map((doc) => doc['name'].toString()).toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: allAreas.map((area) {
                              return CheckboxListTile(
                                title: Text(area),
                                value: _selectedAreas.contains(area),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedAreas.add(area);
                                    } else {
                                      _selectedAreas.remove(area);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huỷ'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('users').doc(docId).update({
                      'role': _roleController.text,
                      'areas': _roleController.text == 'Tổ phần cứng' ? _selectedAreas : [],
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
