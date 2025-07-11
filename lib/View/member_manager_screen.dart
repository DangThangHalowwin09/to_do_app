import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách thành viên')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('name').snapshots(),
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
              final role = user['role'] ?? 'Chưa gắn vị trí';
              final areas = (user['areas'] as List?)?.cast<String>() ?? [];
              final groups = (user['groups'] as List?)?.cast<String>() ?? [];

              return ListTile(
                title: Text(name),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role),
                    if (role == 'Tổ phần cứng') ...[
                      SizedBox(width: 50),
                      Icon(Icons.groups, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(groups.isNotEmpty ? groups.join(', ') : 'Chưa gán nhóm'),
                    ],

                    if (role == 'Y bác sỹ' ) ...[
                      SizedBox(width: 80),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(areas.isNotEmpty ? areas.join(', ') : 'Chưa gán khoa'),
                    ],
                  ],
                ),
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
    final groups = user['groups'] ?? [];
    final email = user['email'];
    final bio = user['bio'];
    final phone = user['phone'];

    final name = user['name'] ?? 'Không rõ';
    final isHardwareTeam = role == 'Tổ phần cứng';
    //final TextEditingController _roleController = TextEditingController(text: role);
    List<String> _selectedAreas = List<String>.from(areas);
    List<String> _selectedGroupAreas = List<String>.from(groups);

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
                    Text((phone != null) ? 'SĐT:  $bio' : 'SĐT: Chưa có DL'),
                    Text((bio != null) ? 'Giới thiệu:  $bio' : 'Giới thiệu: Chưa có DL'),
                    if (role != null) Text('Vị trí: $role'),
                    const SizedBox(height: 10),

                    if (role == 'Tổ phần cứng') ...[
                      Text('Nhóm khu vực đảm nhiệm: '),
                      FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance.collection('groups').orderBy('name').get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        final allAreas = snapshot.data!.docs.map((doc) => doc['name'].toString()).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: allAreas.map((area) {
                            return CheckboxListTile(
                              title: Text(area),
                              value: _selectedGroupAreas.contains(area),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedGroupAreas.add(area);
                                  } else {
                                    _selectedGroupAreas.remove(area);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                      ),
                  ],

                    if (role == 'Y bác sỹ') ...[
                      Text('Khu vực phụ trách: '),
                      FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance.collection('areas').orderBy('name').get(),
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
                      //'role': _roleController.text,
                      'areas': role == 'Y bác sỹ' ? _selectedAreas : [],
                      'groups': role == 'Tổ phần cứng' ? _selectedGroupAreas : [],
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
