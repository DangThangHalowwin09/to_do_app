import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Hộp thoại xác nhận trước khi xoá. Trả về `true` nếu người dùng đồng ý.
Future<bool> confirmDelete(BuildContext context, {required String title, required String message}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.urgent),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Xoá'),
        ),
      ],
    ),
  );
  return result ?? false;
}
