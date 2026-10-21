import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../repositories/error_report_repository.dart';
import '../../services/upload_service.dart';
import '../../services/user_session.dart';

/// Bác sỹ / điều dưỡng gửi phiếu báo hỏng phần mềm / phần cứng cho phòng CNTT.
class AddErrorScreen extends StatefulWidget {
  const AddErrorScreen({super.key});

  @override
  State<AddErrorScreen> createState() => _AddErrorScreenState();
}

class _AddErrorScreenState extends State<AddErrorScreen> {
  static const _software = 'Báo lỗi phần mềm';
  static const _hardware = 'Báo lỗi phần cứng';
  static const _maxImages = 3;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  final _picker = ImagePicker();

  String? _errorType;
  String _priority = ErrorPriority.normal;
  final List<XFile> _images = [];
  final Map<XFile, Uint8List> _previews = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_images.length >= _maxImages) return;
    try {
      // Thu nhỏ ảnh để tải lên nhanh trên mạng bệnh viện.
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 80);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _images.add(file);
        _previews[file] = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được máy ảnh / thư viện ảnh. Hãy kiểm tra quyền truy cập.')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = UserSession.instance;

    setState(() => _isSubmitting = true);
    try {
      final imageUrls = <String>[];
      for (final image in _images) {
        imageUrls.add(await UploadService.uploadImage(image, folder: 'error_images'));
      }
      await ErrorReportRepository.create(
        title: _titleController.text.trim(),
        detail: _detailController.text.trim(),
        errorType: _errorType!,
        location: _errorType == _hardware ? _locationController.text.trim() : '',
        note: _noteController.text.trim(),
        reporterUid: session.uid ?? '',
        reporterName: session.name,
        reporterPhone: session.phone,
        priority: _priority,
        imageUrls: imageUrls,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi báo hỏng thất bại, vui lòng thử lại')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi báo hỏng. Phòng CNTT sẽ được thông báo ngay.')),
    );
    Navigator.pop(context);
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  @override
  Widget build(BuildContext context) {
    final urgent = _priority == ErrorPriority.urgent;

    return Scaffold(
      appBar: AppBar(title: const Text('Báo hỏng')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Mức độ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: ErrorPriority.normal, label: Text('Bình thường'), icon: Icon(Icons.schedule)),
                ButtonSegment(value: ErrorPriority.urgent, label: Text('Khẩn cấp'), icon: Icon(Icons.priority_high_rounded)),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
              style: urgent
                  ? SegmentedButton.styleFrom(selectedBackgroundColor: AppColors.urgentBg, selectedForegroundColor: AppColors.urgent)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              urgent
                  ? 'Chỉ chọn khi ảnh hưởng trực tiếp tới người bệnh (phòng mổ, cấp cứu, hồi sức...). '
                      'Toàn bộ IT sẽ được báo nếu sau 5 phút chưa có người nhận.'
                  : 'Phiếu sẽ được gửi tới nhân viên IT phụ trách khoa của bạn.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Tiêu đề lỗi', hintText: 'Ví dụ: Máy in phòng khám 3 kẹt giấy'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
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
            const SizedBox(height: 16),
            Text('Ảnh đính kèm (tối đa $_maxImages)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final image in _images)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_previews[image]!, width: 88, height: 88, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          tooltip: 'Bỏ ảnh',
                          style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() {
                            _images.remove(image);
                            _previews.remove(image);
                          }),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (_images.length < _maxImages) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (!kIsWeb)
                    OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Chụp ảnh'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn ảnh'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: urgent ? FilledButton.styleFrom(backgroundColor: AppColors.urgent) : null,
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(urgent ? 'Gửi báo hỏng KHẨN' : 'Gửi báo hỏng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
