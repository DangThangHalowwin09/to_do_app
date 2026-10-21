import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/user_role.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_messaging_service.dart';
import '../../repositories/notification_repository.dart';
import '../../services/user_session.dart';
import '../../widgets/notification_permission_card.dart';
import '../notifications/notification_inbox_screen.dart';
import '../auth/login_screen.dart';
import 'home_menu.dart';

/// Màn hình chính sau đăng nhập; nội dung phụ thuộc vào vai trò ([HomeMenu.of]).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Nếu người dùng mở app bằng cách bấm thông báo, chuyển thẳng tới màn hình liên quan.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = FirebaseMessagingService.instance.takePendingRoute();
      if (route != null && mounted) Navigator.pushNamed(context, route);
    });
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final navigator = Navigator.of(context);
    await AuthService().signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = HomeMenu.of(widget.role);
    final name = UserSession.instance.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(menu.title),
        actions: [
          _NotificationBell(uid: UserSession.instance.uid),
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Column(
        children: [
          _Header(name: name, greeting: menu.greeting, welcome: menu.welcome, roleLabel: widget.role.label),
          const NotificationPermissionCard(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    crossAxisSpacing: AppSpacing.sm + 4,
                    mainAxisSpacing: AppSpacing.sm + 4,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: menu.items.length,
                  itemBuilder: (context, index) {
                    final item = menu.items[index];
                    return _MenuTile(
                      icon: item.icon,
                      label: item.label,
                      urgent: item.urgent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item.screen()),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.greeting, required this.welcome, required this.roleLabel});

  final String name;
  final String? greeting;
  final String welcome;
  final String roleLabel;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.last.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusLg + 4)),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(
                _initials,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.blue),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting ?? (name.isEmpty ? 'Xin chào' : 'Xin chào, $name'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  welcome,
                  style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap, required this.urgent});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.urgent : AppColors.blue;
    final tint = urgent ? AppColors.urgentBg : AppColors.progressBg;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(AppSpacing.radius)),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chuông thông báo kèm số chưa đọc.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.uid});

  final String? uid;

  @override
  Widget build(BuildContext context) {
    final id = uid;
    if (id == null) return const SizedBox.shrink();
    return StreamBuilder<int>(
      stream: NotificationRepository.watchUnreadCount(id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return IconButton(
          tooltip: count == 0 ? 'Thông báo' : 'Thông báo, $count chưa đọc',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationInboxScreen())),
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : '$count'),
            child: const Icon(Icons.notifications_rounded),
          ),
        );
      },
    );
  }
}
