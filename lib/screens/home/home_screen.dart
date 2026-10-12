import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/user_role.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_messaging_service.dart';
import '../../services/user_session.dart';
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

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
    final greeting = menu.greeting ?? 'Xin chào: ${UserSession.instance.name}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(menu.title),
        backgroundColor: AppColors.header,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _Banner(greeting: greeting, welcome: menu.welcome),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 110,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: menu.items.length,
              itemBuilder: (context, index) {
                final item = menu.items[index];
                return _MenuTile(
                  icon: item.icon,
                  label: item.label,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.screen()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.greeting, required this.welcome});

  final String greeting;
  final String welcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.header,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            welcome,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: Colors.blue),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
