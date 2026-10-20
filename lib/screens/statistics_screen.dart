import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/empty_state.dart';

/// Thống kê lượt truy cập app trong tháng hiện tại (collection `visits`).
class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _stream() {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return FirebaseFirestore.instance.collection('visits').doc(docId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê truy cập')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _stream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được thống kê');
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data?.data();
          if (data == null) {
            return EmptyState(icon: Icons.bar_chart_rounded, message: 'Chưa có dữ liệu thống kê tháng ${now.month}/${now.year}');
          }

          int value(String key) => (data[key] as num?)?.toInt() ?? 0;
          final platforms = [
            ('Android', Icons.android_rounded, value('platform_Android')),
            ('iOS', Icons.phone_iphone_rounded, value('platform_Ios')),
            ('Web', Icons.language_rounded, value('platform_Web')),
          ];
          final platformTotal = platforms.fold<int>(0, (total, p) => total + p.$3);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text('Tháng ${now.month}/${now.year}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm + 4),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Hôm nay', value: value('todayVisits'), icon: Icons.today_rounded)),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(child: _StatCard(label: 'Tuần này', value: value('weekVisits'), icon: Icons.date_range_rounded)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm + 4),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Tháng này', value: value('monthVisits'), icon: Icons.calendar_month_rounded)),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(child: _StatCard(label: 'Đang online', value: value('onlineCount'), icon: Icons.wifi_tethering_rounded)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Theo nền tảng', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm + 4),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          for (final p in platforms) _PlatformBar(label: p.$1, icon: p.$2, count: p.$3, total: platformTotal),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.blue),
              const SizedBox(height: AppSpacing.sm),
              Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.blue)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformBar extends StatelessWidget {
  const _PlatformBar({required this.label, required this.icon, required this.count, required this.total});

  final String label;
  final IconData icon;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final share = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        label: '$label: $count lượt, ${(share * 100).round()} phần trăm',
        excludeSemantics: true,
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm + 4),
            SizedBox(width: 64, child: Text(label)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 10,
                  backgroundColor: AppColors.progressBg,
                  color: AppColors.blue,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            SizedBox(width: 48, child: Text('$count', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}
