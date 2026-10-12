import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AreaManagerScreen extends StatefulWidget {
  const AreaManagerScreen({super.key});

  @override
  State<AreaManagerScreen> createState() => _AreaManagerScreenState();
}

class _AreaManagerScreenState extends State<AreaManagerScreen> {
  final TextEditingController _areaNameController = TextEditingController();
  String? _selectedGroupId;
  bool _showAddForm = false;

  List<QueryDocumentSnapshot> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final snapshot = await FirebaseFirestore.instance.collection('groups').orderBy('name').get();
    setState(() {
      _groups = snapshot.docs;
    });
  }

  Future<void> _addArea() async {
    final name = _areaNameController.text.trim();
    if (name.isEmpty) return;

    await FirebaseFirestore.instance.collection('areas').add({
      'name': name,
      'groupId': _selectedGroupId, // có thể null
    });

    _areaNameController.clear();
    setState(() {
      _selectedGroupId = null;
      _showAddForm = false;
    });
  }

  Future<void> _editArea(String docId, String currentName, String? currentGroupId) async {
    final controller = TextEditingController(text: currentName);
    String? selectedGroup = currentGroupId;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa khu vực"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: "Tên khu vực")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedGroup,
              items: _groups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Text(group['name']),
                );
              }).toList(),
              onChanged: (value) => selectedGroup = value,
              decoration: const InputDecoration(labelText: "Nhóm (tuỳ chọn)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Huỷ")),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await FirebaseFirestore.instance.collection('areas').doc(docId).update({
                  'name': newName,
                  'groupId': selectedGroup,
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArea(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xoá khu vực"),
        content: const Text("Bạn có chắc muốn xoá khu vực này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xoá")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('areas').doc(docId).delete();
    }
  }

  String _getGroupNameById(String? groupId) {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      return group['name'];
    } catch (e) {
      return "Chưa gán nhóm";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý khu vực")),
      body: Column(
        children: [
          if (_showAddForm)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _areaNameController,
                    decoration: const InputDecoration(
                      labelText: "Tên khu vực",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    items: _groups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group.id,
                        child: Text(group['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGroupId = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Chọn nhóm (có thể bỏ qua)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(onPressed: _addArea, child: const Text("Lưu")),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAddForm = false;
                            _areaNameController.clear();
                            _selectedGroupId = null;
                          });
                        },
                        child: const Text("Huỷ"),
                      ),
                    ],
                  )
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () => setState(() => _showAddForm = true),
                child: const Text("➕ Thêm khu vực"),
              ),
            ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('areas').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final areas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final doc = areas[index];
                    final name = doc['name'] ?? "";
                    final groupId = doc.data().toString().contains('groupId') ? doc['groupId'] : null;
                    final groupName = _getGroupNameById(groupId);

                    return ListTile(
                      title: Text(name),
                      subtitle: Text("Nhóm: $groupName"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editArea(doc.id, name, groupId)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteArea(doc.id)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
