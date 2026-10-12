import 'package:flutter/material.dart';

import '../../repositories/error_report_repository.dart';
import '../../services/user_session.dart';

/// Bác sỹ gửi phiếu báo lỗi phần mềm / phần cứng cho phòng CNTT.
class AddErrorScreen extends StatefulWidget {
  const AddErrorScreen({super.key});

  @override
  State<AddErrorScreen> createState() => _AddErrorScreenState();
}

class _AddErrorScreenState extends State<AddErrorScreen> {
  static const _software = 'Báo lỗi phần mềm';
  static const _hardware = 'Báo lỗi phần cứng';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  String? _errorType;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = UserSession.instance;

    setState(() => _isSubmitting = true);
    try {
      await ErrorReportRepository.create(
        title: _titleController.text.trim(),
        detail: _detailController.text.trim(),
        errorType: _errorType!,
        location: _errorType == _hardware ? _locationController.text.trim() : '',
        note: _noteController.text.trim(),
        reporterName: session.name,
        reporterPhone: session.phone,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi báo lỗi thất bại, vui lòng thử lại')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi báo lỗi')));
    Navigator.pop(context);
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo lỗi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Tiêu đề lỗi'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Chi tiết lỗi'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _errorType,
              decoration: const InputDecoration(labelText: 'Loại lỗi'),
              items: const [
                DropdownMenuItem(value: _software, child: Text(_software)),
                DropdownMenuItem(value: _hardware, child: Text(_hardware)),
              ],
              onChanged: (value) => setState(() => _errorType = value),
              validator: (value) => value == null ? 'Chọn loại lỗi' : null,
            ),
            if (_errorType == _hardware) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Cụ thể khoa/phòng có lỗi'),
                validator: _required,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Gửi báo lỗi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
