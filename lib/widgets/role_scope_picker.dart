import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/constants/user_role.dart';

/// Chọn phạm vi làm việc theo vai trò:
/// - Y bác sỹ: chọn các khoa (`areas`)
/// - Tổ phần cứng: chọn các khu vực hỗ trợ (`groups`)
/// Các vai trò khác không cần chọn gì.
class RoleScopePicker extends StatefulWidget {
  const RoleScopePicker({
    super.key,
    required this.role,
    required this.onAreasChanged,
    required this.onGroupsChanged,
  });

  final UserRole? role;
  final ValueChanged<List<String>> onAreasChanged;
  final ValueChanged<List<String>> onGroupsChanged;

  @override
  State<RoleScopePicker> createState() => _RoleScopePickerState();
}

class _RoleScopePickerState extends State<RoleScopePicker> {
  final _searchController = TextEditingController();
  final _selectedAreas = <String>{};
  final _selectedGroups = <String>{};

  List<String> _areaOptions = [];
  List<String> _groupOptions = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void didUpdateWidget(RoleScopePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _selectedAreas.clear();
      _selectedGroups.clear();
      _searchController.clear();
      // Báo cho form cha sau khi build xong để tránh setState trong lúc build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAreasChanged(const []);
        widget.onGroupsChanged(const []);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final db = FirebaseFirestore.instance;
      final areas = await db.collection('areas').orderBy('name').get();
      final groups = await db.collection('groups').orderBy('name').get();
      if (!mounted) return;
      setState(() {
        _areaOptions = areas.docs.map((d) => d['name'].toString()).toList();
        _groupOptions = groups.docs.map((d) => d['name'].toString()).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Không tải được danh sách. Vui lòng thử lại sau.';
      });
    }
  }

  void _toggle(Set<String> target, String value, bool selected, ValueChanged<List<String>> notify) {
    setState(() => selected ? target.add(value) : target.remove(value));
    notify(target.toList());
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    if (role != UserRole.doctor && role != UserRole.hardTeam) return const SizedBox.shrink();

    final isDoctor = role == UserRole.doctor;
    final title = isDoctor ? 'Chọn khoa:' : 'Chọn khu vực hỗ trợ:';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_loadError != null)
          Text(_loadError!, style: const TextStyle(color: Colors.red))
        else if (isDoctor) ..._doctorOptions()
        else ..._groupOptionsList(),
      ],
    );
  }

  List<Widget> _doctorOptions() {
    final query = _searchController.text.toLowerCase();
    return [
      TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Tìm khoa...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 8),
      for (final area in _areaOptions.where((a) => a.toLowerCase().contains(query)))
        CheckboxListTile(
          title: Text(area),
          value: _selectedAreas.contains(area),
          onChanged: (v) => _toggle(_selectedAreas, area, v == true, widget.onAreasChanged),
        ),
    ];
  }

  List<Widget> _groupOptionsList() => [
        for (final group in _groupOptions)
          CheckboxListTile(
            title: Text(group),
            value: _selectedGroups.contains(group),
            onChanged: (v) => _toggle(_selectedGroups, group, v == true, widget.onGroupsChanged),
          ),
      ];
}
