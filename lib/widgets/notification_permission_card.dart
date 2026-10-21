import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../services/firebase_messaging_service.dart';

/// Thẻ nhắc bật thông báo, hiện trên màn hình chính khi thiết bị / trình duyệt chưa cho phép.
/// Trình duyệt chỉ cho xin quyền sau khi người dùng bấm, nên bản web cần nút này.
class NotificationPermissionCard extends StatefulWidget {
  const NotificationPermissionCard({super.key});

  @override
  State<NotificationPermissionCard> createState() => _NotificationPermissionCardState();
}

class _NotificationPermissionCardState extends State<NotificationPermissionCard> {
  AuthorizationStatus? _status;
  bool _dismissed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseMessagingService.isSupported) {
      FirebaseMessagingService.instance.permissionStatus().then((s) {
        if (mounted) setState(() => _status = s);
      });
    }
  }

  Future<void> _enable() async {
    setState(() => _busy = true);
    final status = await FirebaseMessagingService.instance.requestPermissionAndRegister();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = status;
    });
    if (status == AuthorizationStatus.authorized) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bật thông báo trên thiết bị này')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final needsPrompt = status == AuthorizationStatus.notDetermined || status == AuthorizationStatus.denied;
    if (_dismissed || !needsPrompt) return const SizedBox.shrink();

    final denied = status == AuthorizationStatus.denied;
    final text = denied
        ? (kIsWeb
            ? 'Trình duyệt đang chặn thông báo. Bấm biểu tượng ổ khoá cạnh địa chỉ trang → Thông báo → Cho phép.'
            : 'Thông báo đang tắt. Vào Cài đặt → Ứng dụng → UBNA Manager → Thông báo để bật.')
        : 'Bật thông báo để được báo ngay khi có phiếu báo hỏng, việc được giao hoặc sắp đến hạn.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: AppColors.pendingBg,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.notifications_active_outlined, color: AppColors.pending),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text),
                    if (!denied) ...[
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _busy ? null : _enable,
                        child: Text(_busy ? 'Đang bật...' : 'Bật thông báo'),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Ẩn',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _dismissed = true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
