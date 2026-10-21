import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../services/firebase_messaging_service.dart';
import '../../services/user_session.dart';
import '../../widgets/empty_state.dart';

/// Hộp thư thông báo: lưu mọi thông báo đã gửi cho người dùng, kể cả khi push bị tắt.
class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  static final _time = DateFormat('HH:mm dd/MM');

  void _open(BuildContext context, String uid, AppNotification n) {
    if (!n.read) NotificationRepository.markRead(uid, n.id);
    final route = FirebaseMessagingService.routeFor({'type': n.type});
    if (route != null) Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final uid = UserSession.instance.uid;
    if (uid == null) return const Scaffold(body: EmptyState(icon: Icons.lock_outline, message: 'Vui lòng đăng nhập'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            tooltip: 'Đánh dấu tất cả đã đọc',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => NotificationRepository.markAllRead(uid),
          ),
        ],
      ),
      body: Column(
        children: [
          const _PermissionBanner(),
          Expanded(
            child: StreamBuilder<List<AppNotification>>(
              stream: NotificationRepository.watch(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được thông báo');
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                if (items.isEmpty) return const EmptyState(icon: Icons.notifications_none_rounded, message: 'Chưa có thông báo nào');

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = items[i];
                    return ListTile(
                      tileColor: n.read ? null : AppColors.progressBg.withValues(alpha: 0.5),
                      leading: Icon(_iconFor(n.type), color: n.read ? AppColors.textSecondary : AppColors.blue),
                      title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700)),
                      subtitle: Text(n.body, maxLines: 3, overflow: TextOverflow.ellipsis),
                      trailing: n.createdAt == null ? null : Text(_time.format(n.createdAt!), style: Theme.of(context).textTheme.bodySmall),
                      onTap: () => _open(context, uid, n),
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

  IconData _iconFor(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment_rounded;
      case 'rating':
        return Icons.star_rate_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }
}

/// Nhắc bật quyền thông báo nếu thiết bị / trình duyệt chưa cho phép.
class _PermissionBanner extends StatefulWidget {
  const _PermissionBanner();

  @override
  State<_PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends State<_PermissionBanner> {
  AuthorizationStatus? _status;

  @override
  void initState() {
    super.initState();
    FirebaseMessagingService.instance.permissionStatus().then((s) {
      if (mounted) setState(() => _status = s);
    });
  }

  Future<void> _enable() async {
    final status = await FirebaseMessagingService.instance.requestPermissionAndRegister();
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    if (!FirebaseMessagingService.isSupported) {
      return const _Banner(text: 'Trình duyệt này chưa nhận được thông báo đẩy. Bạn vẫn xem đầy đủ thông báo tại đây.');
    }
    final status = _status;
    if (status == null || status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional) {
      return const SizedBox.shrink();
    }
    if (status == AuthorizationStatus.denied) {
      return _Banner(
        text: kIsWeb
            ? 'Bạn đã chặn thông báo. Bấm biểu tượng ổ khoá cạnh địa chỉ trang để cho phép lại.'
            : 'Thông báo đang bị tắt. Vào Cài đặt điện thoại → Ứng dụng → UBNA Manager → Thông báo để bật lại.',
      );
    }
    return _Banner(
      text: 'Bật thông báo để được báo ngay khi có phiếu lỗi hoặc việc được giao.',
      action: FilledButton(onPressed: _enable, child: const Text('Bật thông báo')),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.pendingBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(color: AppColors.textPrimary)),
          if (action != null) ...[const SizedBox(height: 8), action!],
        ],
      ),
    );
  }
}
