import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/app_logger.dart';
import '../../core/utils/contact_launcher.dart';
import '../../repositories/error_report_repository.dart';
import '../../repositories/rating_repository.dart';
import '../../repositories/staff_repository.dart';
import '../../services/user_session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/status_chip.dart';
import 'add_error_screen.dart';

/// Danh sách phiếu báo lỗi. Bác sỹ: gọi nhanh NV IT phụ trách + tạo phiếu. NV IT: nhận xử lý / hoàn thành.
class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  final _session = UserSession.instance;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late final Future<List<ItStaff>> _staffFuture =
      _session.isClinical ? StaffRepository.forAreas(_session.areas) : Future.value(const []);

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on StateError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      AppLog.e('Cập nhật phiếu lỗi thất bại', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thao tác thất bại, vui lòng thử lại')),
      );
    }
  }

  Future<void> _rate(String id, Map<String, dynamic> data) async {
    final staffName = (data['nameStaff'] ?? 'nhân viên IT') as String;
    final result = await showRatingDialog(
      context,
      title: 'Đánh giá $staffName',
      subtitle: 'Phiếu: ${data['errorTitle'] ?? ''}',
    );
    if (result == null || !mounted) return;
    await runWithFeedback(
      context,
      () => RatingRepository.rateError(
        errorId: id,
        errorTitle: (data['errorTitle'] ?? '') as String,
        staffUid: (data['staffUid'] ?? '') as String,
        staffName: staffName,
        stars: result.stars,
        comment: result.comment,
      ),
      success: 'Cảm ơn bạn đã đánh giá',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo lỗi')),
      body: Column(
        children: [
          if (_session.isClinical) _StaffPanel(future: _staffFuture, doctorName: _session.name),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ErrorReportRepository.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Không tải được danh sách lỗi'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text('Không có lỗi nào'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) => _ErrorCard(
                    id: docs[index].id,
                    data: docs[index].data(),
                    dateFormat: _dateFormat,
                    canHandle: _session.isItMember,
                    onTakeOver: (id) => _run(
                      () => ErrorReportRepository.takeOver(id, staffUid: _session.uid ?? '', staffName: _session.name),
                    ),
                    onDone: (id) => _run(() => ErrorReportRepository.markDone(id)),
                    canRate: (data) =>
                        data['isDone'] == true &&
                        data['reporterUid'] == _session.uid &&
                        data['rating'] == null &&
                        (data['staffUid'] ?? '') != '',
                    onRate: _rate,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _session.isClinical
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddErrorScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Báo lỗi'),
            )
          : null,
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.id,
    required this.data,
    required this.dateFormat,
    required this.canHandle,
    required this.onTakeOver,
    required this.onDone,
    required this.canRate,
    required this.onRate,
  });

  final String id;
  final Map<String, dynamic> data;
  final DateFormat dateFormat;
  final bool canHandle;
  final ValueChanged<String> onTakeOver;
  final ValueChanged<String> onDone;
  final bool Function(Map<String, dynamic> data) canRate;
  final void Function(String id, Map<String, dynamic> data) onRate;

  @override
  Widget build(BuildContext context) {
    final address = (data['address'] ?? '') as String;
    final time = (data['timeErrorStart'] as Timestamp?)?.toDate();
    final isTakeOver = data['isTakeOver'] == true;
    final isDone = data['isDone'] == true;

    final status = isDone ? WorkStatus.done : (isTakeOver ? WorkStatus.inProgress : WorkStatus.pending);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text((data['errorTitle'] ?? '') as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              StatusChip(status),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loại: ${data['errorType'] ?? ''}'),
            if (address.isNotEmpty) Text('Phòng bị hỏng: $address'),
            Text('Chi tiết: ${data['clarifyTitle'] ?? ''}'),
            Text('SĐT: ${data['phoneContact'] ?? ''}'),
            Text('Ghi chú: ${data['note'] ?? ''}'),
            Text('Thời gian lỗi: ${time != null ? dateFormat.format(time) : ''}'),
            if (isTakeOver) Text('Người nhận: ${data['nameStaff'] ?? ''}'),
            Text('Người báo: ${data['nameDoctor'] ?? ''}'),
            if (data['rating'] is num) ...[
              const SizedBox(height: 4),
              StarDisplay(value: (data['rating'] as num).toDouble()),
              if ((data['ratingComment'] ?? '').toString().isNotEmpty) Text('“${data['ratingComment']}”'),
            ],
            if (canRate(data)) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onRate(id, data),
                  icon: const Icon(Icons.star_outline_rounded),
                  label: const Text('Đánh giá nhân viên xử lý'),
                ),
              ),
            ],
            if (canHandle && !isDone) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => isTakeOver ? onDone(id) : onTakeOver(id),
                  child: Text(isTakeOver ? 'Hoàn thành' : 'Nhận xử lý'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StaffPanel extends StatelessWidget {
  const _StaffPanel({required this.future, required this.doctorName});

  final Future<List<ItStaff>> future;
  final String doctorName;

  void _call(ItStaff staff) {
    ContactLauncher.call(staff.phone);
    FirebaseAnalytics.instance.logEvent(
      name: 'call_IT_staff',
      parameters: {
        'doctor_name': doctorName,
        'it_staff_name': staff.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cấp thiết: gọi ngay nhân viên IT phụ trách.\nKhông cấp thiết: nhấn nút "Báo lỗi" để điền phiếu hỗ trợ.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<ItStaff>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final staff = snapshot.data ?? const [];
              if (staff.isEmpty) {
                return const Text('Không tìm thấy nhân viên IT phụ trách.', style: TextStyle(color: Colors.black54));
              }
              return Column(
                children: [
                  for (final s in staff)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: Text(s.phone),
                        trailing: IconButton.filledTonal(
                          tooltip: 'Gọi ${s.name}',
                          onPressed: s.phone.isEmpty ? null : () => _call(s),
                          icon: const Icon(Icons.call, color: Colors.green),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
