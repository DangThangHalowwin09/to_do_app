import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/onboarding_store.dart';

/// 2 màn hình giới thiệu app, hiện ở lần mở đầu tiên (có thể xem lại từ trang chủ).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  /// Gọi khi bấm "Bắt đầu" hoặc "Bỏ qua".
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = <_PageData>[
    _PageData(
      icon: Icons.local_hospital_rounded,
      title: 'Chào mừng đến với UBNA Manager',
      body: 'Ứng dụng nội bộ dành cho cán bộ, nhân viên Bệnh viện Ung bướu Nghệ An, '
          'giúp quản lý công việc nhanh gọn và minh bạch hơn.',
      points: [
        _Point(Icons.build_circle_rounded, 'Báo lỗi CNTT chỉ vài chạm'),
        _Point(Icons.assignment_turned_in_rounded, 'Giao việc rõ người, rõ hạn'),
        _Point(Icons.event_available_rounded, 'Tra cứu lịch trực mọi lúc'),
      ],
    ),
    _PageData(
      icon: Icons.notifications_active_rounded,
      title: 'Theo dõi công việc hiệu quả hơn',
      body: 'Mỗi vai trò thấy đúng chức năng mình cần, và được báo ngay khi có việc mới.',
      points: [
        _Point(Icons.notifications_active_rounded, 'Nhận thông báo khi có phiếu lỗi hoặc việc được giao'),
        _Point(Icons.timeline_rounded, 'Xem trạng thái: chờ xử lý, đang xử lý, hoàn thành'),
        _Point(Icons.verified_user_rounded, 'Đăng nhập theo vai trò, thông tin được bảo mật'),
      ],
    ),
  ];

  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingStore.markSeen();
    if (mounted) widget.onFinished();
  }

  void _go(int page) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    // Luôn cho phép bỏ qua (không ép người dùng xem hết).
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      child: const Text('Bỏ qua'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
                  ),
                ),
                _Dots(count: _pages.length, index: _index),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                  child: Row(
                    children: [
                      if (_index > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _go(_index - 1),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                            ),
                            child: const Text('Quay lại'),
                          ),
                        ),
                      if (_index > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isLast ? _finish : () => _go(_index + 1),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.blue,
                          ),
                          child: Text(_isLast ? 'Bắt đầu' : 'Tiếp tục'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData({required this.icon, required this.title, required this.body, required this.points});

  final IconData icon;
  final String title;
  final String body;
  final List<_Point> points;
}

class _Point {
  const _Point(this.icon, this.text);

  final IconData icon;
  final String text;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _PageData data;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ExcludeSemantics(child: Icon(data.icon, size: 56, color: AppColors.blue)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(color: Colors.white, fontSize: 26),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final point in data.points)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(child: Icon(point.icon, color: Colors.white, size: 28)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(point.text, style: text.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Trang ${index + 1} trên $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == index ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
