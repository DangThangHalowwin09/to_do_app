import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

enum WorkStatus {
  pending('Chờ xử lý', Icons.hourglass_empty_rounded, AppColors.pending, AppColors.pendingBg),
  inProgress('Đang xử lý', Icons.autorenew_rounded, AppColors.progress, AppColors.progressBg),
  done('Hoàn thành', Icons.check_circle_rounded, AppColors.done, AppColors.doneBg);

  const WorkStatus(this.label, this.icon, this.color, this.background);

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
}

/// Nhãn trạng thái: luôn có biểu tượng + chữ nên không phụ thuộc vào màu.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Trạng thái: ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: status.background, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 16, color: status.color),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: status.color),
            ),
          ],
        ),
      ),
    );
  }
}
