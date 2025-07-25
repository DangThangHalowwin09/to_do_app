import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/helper.dart';

class SearchAreaScreen extends StatefulWidget {
  const SearchAreaScreen({Key? key}) : super(key: key);

  @override
  State<SearchAreaScreen> createState() => _SearchAreaScreenState();
}

class _SearchAreaScreenState extends State<SearchAreaScreen> {
  final TextEditingController _areaController = TextEditingController();
  List<String> _areaSuggestions = [];
  Map<String, dynamic> _areaMap = {}; // {areaName: groupID}
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('areas').get();
      final areas = snapshot.docs;

      final List<String> suggestions = [];
      final Map<String, dynamic> areaMap = {};

      for (var doc in areas) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String?;
        final groupDocumentID = data['groupId'];

        if (name != null) {
          suggestions.add(name);
          if (groupDocumentID != null) {
            areaMap[name] = groupDocumentID;
          }
        }
      }

      setState(() {
        _areaSuggestions = suggestions;
        _areaMap = areaMap;
      });
    } catch (e) {
      print('Lỗi khi load areas: $e');
      _showDialog(
        title: 'Lỗi',
        content: 'Không thể tải dữ liệu khu vực. Vui lòng kiểm tra kết nối.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsersByArea(String areaName) async {
    FocusScope.of(context).unfocus(); // ẩn bàn phím
    setState(() => _isLoading = true);

    try {
      final groupIdRaw = _areaMap[areaName];
      final groupID = await GroupHelper.getGroupNameByID(groupIdRaw);

      if (groupID == null) {
        _showDialog(
          title: 'Không tìm thấy',
          content: 'Không có nhân viên IT phụ trách khu vực này.',
        );
        return;
      }

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('groups', arrayContains: groupID)
          .get();

      if (userSnapshot.docs.isEmpty) {
        _showDialog(
          title: 'Không tìm thấy',
          content: 'Không có nhân viên IT phụ trách khu vực này.',
        );
        return;
      }

      for (final doc in userSnapshot.docs) {
        final name = doc['name'];
        final phone = doc['phone'];
        _showDialog(
          title: 'Nhân viên phụ trách',
          content: 'Tên: $name\nSĐT: $phone',
          phoneNumber: phone,
        );
      }
    } catch (e) {
      print('Lỗi khi tìm nhân viên: $e');
      _showDialog(
        title: 'Lỗi',
        content: 'Có lỗi xảy ra khi tra cứu nhân viên.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog({required String title, required String content, String? phoneNumber}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          if (phoneNumber != null)
            TextButton.icon(
              icon: const Icon(Icons.call, color: Colors.green),
              label: const Text('Gọi'),
              onPressed: () {
                final uri = Uri(scheme: 'tel', path: phoneNumber);
                print(uri);
                launchUrl(uri);
              },
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu nhân viên phụ trách'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return _areaSuggestions.where((area) =>
                        area.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    _areaController.text = selection;
                    _searchUsersByArea(selection);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Nhập tên khoa/khu vực',
                        hintText: 'Ví dụ: CNTT, HCQT...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (_areaController.text.isNotEmpty)
                  Text('Khu vực đã chọn: ${_areaController.text}',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
