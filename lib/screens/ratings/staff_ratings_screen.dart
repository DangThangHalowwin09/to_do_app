import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/staff_rating.dart';
import '../../repositories/rating_repository.dart';
import '../../services/user_session.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/feedback.dart';
import '../../widgets/star_rating.dart';

/// Danh sách nhân viên IT kèm điểm đánh giá.
/// - Bác sỹ / điều dưỡng: chạm để đánh giá chung (mỗi người một lượt, sửa được).
/// - Admin: chạm để xem chi tiết các nhận xét.
class StaffRatingsScreen extends StatelessWidget {
  const StaffRatingsScreen({super.key});

  Future<void> _rate(BuildContext context, ItStaffEntry staff) async {
    final existing = await RatingRepository.myGeneralReview(staff.uid);
    if (!context.mounted) return;
    final result = await showRatingDialog(
      context,
      title: 'Đánh giá ${staff.name}',
      subtitle: 'Đánh giá chung về thái độ và chất lượng hỗ trợ',
      initialStars: existing?.stars ?? 0,
      initialComment: existing?.comment ?? '',
    );
    if (result == null || !context.mounted) return;
    await runWithFeedback(
      context,
      () => RatingRepository.saveGeneralReview(
        staffUid: staff.uid,
        staffName: staff.name,
        stars: result.stars,
        comment: result.comment,
      ),
      success: 'Cảm ơn bạn đã đánh giá',
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    final canRate = session.isClinical;

    return Scaffold(
      appBar: AppBar(title: Text(canRate ? 'Đánh giá nhân viên IT' : 'Đánh giá nhân viên')),
      body: StreamBuilder<List<ItStaffEntry>>(
        stream: RatingRepository.watchItStaff(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được dữ liệu');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final staff = snapshot.data!;
          if (staff.isEmpty) return const EmptyState(icon: Icons.groups_outlined, message: 'Chưa có nhân viên IT');

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              if (canRate)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('Chạm vào một nhân viên để đánh giá. Bạn có thể sửa đánh giá của mình bất cứ lúc nào.'),
                ),
              for (final s in staff)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(child: Text(s.name.isEmpty ? '?' : s.name.trim().split(' ').last[0].toUpperCase())),
                    title: Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.role),
                        const SizedBox(height: 2),
                        StarDisplay(value: s.summary.average, count: s.summary.count),
                      ],
                    ),
                    trailing: Icon(canRate ? Icons.rate_review_outlined : Icons.chevron_right),
                    onTap: () => canRate
                        ? _rate(context, s)
                        : Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StaffRatingDetailScreen(staffUid: s.uid, staffName: s.name)),
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Chi tiết các lượt đánh giá của một nhân viên (Admin xem bất kỳ ai, nhân viên IT xem của mình).
class StaffRatingDetailScreen extends StatelessWidget {
  const StaffRatingDetailScreen({super.key, required this.staffUid, required this.staffName});

  /// Màn hình "Đánh giá của tôi" cho nhân viên IT đang đăng nhập.
  factory StaffRatingDetailScreen.mine() {
    final s = UserSession.instance;
    return StaffRatingDetailScreen(staffUid: s.uid ?? '', staffName: s.name);
  }

  final String staffUid;
  final String staffName;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text('Đánh giá – $staffName')),
      body: StreamBuilder<List<StaffRating>>(
        stream: RatingRepository.watchForStaff(staffUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được đánh giá');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final ratings = snapshot.data!;
          if (ratings.isEmpty) return const EmptyState(icon: Icons.star_outline_rounded, message: 'Chưa có đánh giá nào');

          final avg = ratings.fold<int>(0, (acc, r) => acc + r.stars) / ratings.length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarDisplay(value: avg, size: 24),
                            Text('${ratings.length} lượt đánh giá gần nhất'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final r in ratings)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StarDisplay(value: r.stars.toDouble()),
                            const Spacer(),
                            if (r.createdAt != null) Text(dateFormat.format(r.createdAt!), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.kind == StaffRating.kindError ? 'Phiếu lỗi: ${r.errorTitle ?? ''}' : 'Đánh giá chung',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (r.comment.isNotEmpty) Text('“${r.comment}”'),
                        Text('— ${r.raterName}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
