import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Một dòng trong danh sách quản trị: nội dung + nút sửa / xoá (có tooltip, vùng chạm 48dp).
class AdminListTile extends StatelessWidget {
  const AdminListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.md)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Sửa',
                  icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Xoá',
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.urgent),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
