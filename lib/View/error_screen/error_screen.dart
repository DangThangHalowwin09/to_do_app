import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/helper.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  String? _role;
  String? _name;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }


  Future<void> _fetchCurrentUserData() async {
    final data = await GetCurrentUserInfor.fetchCurrentUserData();
    setState(() {
      _name = data['name'];
      _role = data['role'];
    });
  }

  Future<void> _takeOverError(DocumentSnapshot errorDoc) async {
    await errorDoc.reference.update({
      'isTakeOver': true,
      'timeTakeOver': Timestamp.now(),
      'nameStaff': _name ?? '',
    });
  }

  Future<void> _markAsDone(DocumentSnapshot errorDoc) async {
    await errorDoc.reference.update({
      'isDone': true,
      'timeDone': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách lỗi')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance.collection('errors').orderBy('timeErrorStart', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Không có lỗi nào'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final errorTitle = data['errorTitle'] ?? '';
              final clarifyTitle = data['clarifyTitle'] ?? '';
              final errorType = data['errorType'] ?? '';
              final address = data['address'] ?? '';
              final phoneContact = data['phoneContact'] ?? '';
              final note = data['note'] ?? '';
              final nameStaff = data['nameStaff'] ?? '';
              final timeErrorStart = (data['timeErrorStart'] as Timestamp?)?.toDate();
              final isTakeOver = data['isTakeOver'] ?? false;
              final isDone = data['isDone'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(errorTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại: $errorType'),
                      if (address.isNotEmpty) Text('Địa điểm: $address'),
                      Text('Chi tiết: $clarifyTitle'),
                      Text('SĐT: $phoneContact'),
                      Text('Ghi chú: $note'),
                      Text('Thời gian lỗi: ${timeErrorStart != null ? dateFormat.format(timeErrorStart) : ''}'),
                      if (isTakeOver) Text('Người nhận: $nameStaff'),
                      if (isDone) const Text('✅ Đã hoàn thành'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (RoleKey.isITMembers(_role) && !isTakeOver)
                        ElevatedButton(
                          onPressed: () => _takeOverError(doc),
                          child: const Text('Nhận xử lý'),
                        ),
                      if (RoleKey.isITMembers(_role) && isTakeOver && !isDone)
                        ElevatedButton(
                          onPressed: () => _markAsDone(doc),
                          child: const Text('Hoàn thành'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _role == 'Y bác sỹ'
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewErrorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class ErrorDetailScreen extends StatefulWidget {
  final DocumentSnapshot errorDoc;
  const ErrorDetailScreen({Key? key, required this.errorDoc}) : super(key: key);

  @override
  State<ErrorDetailScreen> createState() => _ErrorDetailScreenState();
}

class _ErrorDetailScreenState extends State<ErrorDetailScreen> {
  String? currentUserName;
  String? currentUserRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      currentUserName = userDoc['name'];
      currentUserRole = userDoc['role'];
      isLoading = false;
    });
  }

  Future<void> takeOver() async {
    await widget.errorDoc.reference.update({
      'isTakeOver': true,
      'timeTakeOver': FieldValue.serverTimestamp(),
      'nameStaff': currentUserName,
    });
  }

  Future<void> markDone() async {
    await widget.errorDoc.reference.update({
      'isDone': true,
      'timeDone': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết lỗi')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = widget.errorDoc.data() as Map<String, dynamic>;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final timeErrorStart = (data['timeErrorStart'] as Timestamp?)?.toDate();
    final timeTakeOver = (data['timeTakeOver'] as Timestamp?)?.toDate();
    final timeDone = (data['timeDone'] as Timestamp?)?.toDate();

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết lỗi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiêu đề lỗi: ${data['errorTitle'] ?? ''}'),
            SizedBox(height: 8),
            Text('Chi tiết: ${data['clarifyTitle'] ?? ''}'),
            SizedBox(height: 8),
            if (data['address'] != '') Text('Địa điểm: ${data['address']}'),
            SizedBox(height: 8),
            if (timeErrorStart != null)
              Text('Bắt đầu: ${dateFormat.format(timeErrorStart)}'),
            SizedBox(height: 8),
            Text('Người nhận: ${data['nameStaff'] ?? ''}'),
            if (data['isTakeOver'] == true && timeTakeOver != null)
              Text('Thời gian nhận việc: ${dateFormat.format(timeTakeOver)}'),
            if (data['isDone'] == true && timeDone != null)
              Text('Thời gian hoàn thành: ${dateFormat.format(timeDone)}'),
            SizedBox(height: 16),
            if ((currentUserRole == 'Admin' || currentUserRole == 'Tổ phần mềm' || currentUserRole == 'Tổ phần cứng') && data['isTakeOver'] == false)
              ElevatedButton(
                onPressed: takeOver,
                child: Text('Nhận việc'),
              ),
            if ((currentUserRole == 'Admin' || currentUserRole == 'Tổ phần mềm' || currentUserRole == 'Tổ phần cứng') && data['isTakeOver'] == true && data['isDone'] == false)
              ElevatedButton(
                onPressed: markDone,
                child: Text('Hoàn thành'),
              ),
          ],
        ),
      ),
    );
  }
}




class AddNewErrorScreen extends StatefulWidget {
  const AddNewErrorScreen({super.key});

  @override
  State<AddNewErrorScreen> createState() => _AddNewErrorScreenState();
}

class _AddNewErrorScreenState extends State<AddNewErrorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _errorTitleController = TextEditingController();
  final TextEditingController _clarifyTitleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  //String? _urgencyLevel;

  String? _errorType; // "Báo lỗi phần mềm" hoặc "Báo lỗi phần cứng"
 /* DateTime? _timeErrorStart;

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _timeErrorStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _timeErrorStart != null
          ? TimeOfDay.fromDateTime(_timeErrorStart!)
          : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      _timeErrorStart = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }*/

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _errorType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return;
    }

    final data = {
      'errorTitle': _errorTitleController.text,
      'clarifyTitle': _clarifyTitleController.text,
      'phoneContact': _phoneController.text,
      'address': _errorType == 'Báo lỗi phần cứng' ? _addressController.text : '',
      'timeErrorStart': Timestamp.now(),//Timestamp.fromDate(_timeErrorStart!),
      'note': _noteController.text,
      'isTakeOver': false,
      'timeTakeOver': null,
      'isDone': false,
      'timeDone': null,
      'nameStaff': '', // sẽ cập nhật khi NV phần mềm/cứng nhận xử lý
      'errorType': _errorType,
    };

    await FirebaseFirestore.instance.collection('errors').add(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi báo lỗi')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    //final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('Báo lỗi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _errorType,
                decoration: InputDecoration(labelText: 'Loại lỗi'),
                items: [
                  DropdownMenuItem(
                    value: 'Báo lỗi phần mềm',
                    child: Text('Báo lỗi phần mềm'),
                  ),
                  DropdownMenuItem(
                    value: 'Báo lỗi phần cứng',
                    child: Text('Báo lỗi phần cứng'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _errorType = value);
                },
                validator: (value) => value == null ? 'Chọn loại lỗi' : null,
              ),
              TextFormField(
                controller: _errorTitleController,
                decoration: InputDecoration(labelText: 'Tiêu đề lỗi'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _clarifyTitleController,
                decoration: InputDecoration(labelText: 'Chi tiết lỗi'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'SĐT liên hệ'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              if (_errorType == 'Báo lỗi phần cứng')
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Địa điểm lỗi'),
                  validator: (value) {
                    if (_errorType == 'Báo lỗi phần cứng' && value!.isEmpty) {
                      return 'Vui lòng nhập địa điểm';
                    }
                    return null;
                  },
                ),
              /*ListTile(
                title: Text(
                  _timeErrorStart == null
                      ? 'Chọn thời gian bắt đầu hỏng'
                      : 'Bắt đầu: ${dateFormat.format(_timeErrorStart!)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),*/
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Ghi chú'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Gửi báo lỗi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
