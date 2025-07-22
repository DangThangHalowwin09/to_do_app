import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersITScreen extends StatelessWidget {
  const MembersITScreen({super.key});

  // Hàm hiển thị dialog chi tiết người dùng (giả định bạn đã định nghĩa)
  void _showUserDetailsDialog(BuildContext context, Map<String, dynamic> user, String docId) {
    final role = user['role'] ?? '';
    final areas = user['areas'] ?? [];
    final groups = user['groups'] ?? [];
    final email = user['email'];
    final bio = user['bio'];
    final phone = user['phone'];
    final idDuty = user['idDuty'];

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
                    Text((phone != null) ? 'SĐT:  $phone' : 'SĐT: Chưa có DL'),
                    Text((bio != null) ? 'Giới thiệu:  $bio' : 'Giới thiệu: Chưa có DL'),
                    if (role != null) Text('Vị trí: $role'),
                    if (idDuty != null) Text('Mã trực: $idDuty'),
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
                      'idDuty': idDuty,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhân viên IT'),
        elevation: 0, // Tùy chọn: làm phẳng AppBar
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', whereIn: ['Tổ phần cứng', 'Tổ phần mềm'])
            .orderBy('role', descending: true) // Thêm lại orderBy, giả định chỉ mục đã tạo
            // // Thêm lại orderBy, giả định chỉ mục đã tạo
            .orderBy('groups', descending: false)
            .orderBy('name', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          // Xử lý lỗi
          if (snapshot.hasError) {
            print('Lỗi Firestore: ${snapshot.error}'); // In lỗi để debug
            return const Center(
              child: Text(
                'Đã xảy ra lỗi khi tải dữ liệu',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // Xử lý trạng thái chờ
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kiểm tra dữ liệu rỗng
          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Không có nhân viên nào trong danh sách',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Hiển thị danh sách
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;
              final name = user['name'] ?? 'Chưa có tên';
              final role = user['role'] ?? 'Chưa gắn vị trí';
              final groups = (user['groups'] as List?)?.cast<String>() ?? [];

              return ListTile(
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role),
                    if (role == 'Tổ phần cứng') ...[
                      const SizedBox(width: 10), // Giảm khoảng cách cho gọn
                      Icon(
                        role == 'Tổ phần cứng'
                            ? Icons.hardware
                            : Icons.code, // Icon phù hợp với vai trò
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          groups.isNotEmpty ? groups.join(', ') : 'Chưa gán nhóm',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => _showUserDetailsDialog(context, user, docId),
              );
            },
          );
        },
      ),
    );
  }
}

class MembersDoctorScreen extends StatelessWidget {
  const MembersDoctorScreen({super.key});

  void _showUserDetailsDialog(
      BuildContext context, Map<String, dynamic> user, String docId) {
    final role = user['role'] ?? '';
    final areas = (user['areas'] as List?)?.cast<String>() ?? [];
    final groups = (user['groups'] as List?)?.cast<String>() ?? [];
    final email = user['email'];
    final bio = user['bio'];
    final phone = user['phone'];
    final idDuty = user['idDuty'] ?? 'Không trực';
    final name = user['name'] ?? 'Không rõ';

    List<String> _selectedAreas = List<String>.from(areas);
    List<String> _selectedGroups = List<String>.from(groups);

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
                    Text('SĐT: ${phone ?? 'Chưa có DL'}'),
                    Text('Giới thiệu: ${bio ?? 'Chưa có DL'}'),
                    //if (role.isNotEmpty) Text('Vị trí: $role'),
                    if (idDuty.isNotEmpty) Text('Mã trực: $idDuty'),
                    const SizedBox(height: 10),

                    if (role == 'Y bác sỹ') ...[
                      const Text('Khu vực phụ trách:'),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('areas')
                            .orderBy('name')
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final allAreas = snapshot.data!.docs
                              .map((doc) => doc['name'].toString())
                              .toList();
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
                      ),
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
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({
                        'areas': _selectedAreas,
                        'idDuty': idDuty,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cập nhật thành công')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Y bác sỹ'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', whereIn: ['Y bác sỹ'])
            .orderBy('role', descending: true) // Thêm lại orderBy, giả định chỉ mục đã tạo
        // // Thêm lại orderBy, giả định chỉ mục đã tạo
            .orderBy('areas', descending: false)
            .orderBy('name', descending: false)// Thêm orderBy, cần tạo chỉ mục
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Lỗi Firestore: ${snapshot.error}');
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error.toString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Không có Y bác sỹ trong danh sách',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;
              final name = user['name'] ?? 'Chưa có tên';
              final role = user['role'] ?? 'Chưa gắn vị trí';
              final idDuty = user['idDuty'] ?? 'Không trực';
              final areas = (user['areas'] as List?)?.cast<String>() ?? [];

              return ListTile(
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text(role),
                    if (role == 'Y bác sỹ') ...[
                      //const SizedBox(width: 10), // Giảm khoảng cách
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          areas.isNotEmpty ? areas.join(', ') : 'Chưa gán khoa',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => _showUserDetailsDialog(context, user, docId),
              );
            },
          );
        },
      ),
    );
  }
}

