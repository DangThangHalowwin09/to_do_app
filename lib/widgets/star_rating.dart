import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

const _starColor = Color(0xFFB45309); // cam đậm, tương phản đủ trên nền trắng

/// Hiển thị số sao (chỉ đọc), kèm điểm dạng số cho trình đọc màn hình.
class StarDisplay extends StatelessWidget {
  const StarDisplay({super.key, required this.value, this.count, this.size = 18});

  final double value;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = count == null
        ? '${value.toStringAsFixed(1)} trên 5 sao'
        : (count == 0 ? 'Chưa có đánh giá' : '${value.toStringAsFixed(1)} trên 5 sao, $count lượt');
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              value >= i ? Icons.star_rounded : (value >= i - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
              size: size,
              color: _starColor,
            ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              count == 0 ? 'Chưa có' : '${value.toStringAsFixed(1)} ($count)',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chọn số sao 1–5; mỗi sao là một nút 48dp có nhãn riêng.
class StarInput extends StatelessWidget {
  const StarInput({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['Rất tệ', 'Chưa tốt', 'Bình thường', 'Tốt', 'Rất tốt'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                tooltip: '$i sao – ${_labels[i - 1]}',
                iconSize: 36,
                onPressed: () => onChanged(i),
                icon: Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded, color: _starColor),
              ),
          ],
        ),
        Text(
          value == 0 ? 'Chạm để chọn số sao' : _labels[value - 1],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Hộp thoại đánh giá: số sao + nhận xét. Trả về `(stars, comment)` hoặc `null` nếu huỷ.
Future<({int stars, String comment})?> showRatingDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  int initialStars = 0,
  String initialComment = '',
}) {
  return showDialog<({int stars, String comment})>(
    context: context,
    builder: (_) => _RatingDialog(title: title, subtitle: subtitle, initialStars: initialStars, initialComment: initialComment),
  );
}

class _RatingDialog extends StatefulWidget {
  const _RatingDialog({required this.title, this.subtitle, required this.initialStars, required this.initialComment});

  final String title;
  final String? subtitle;
  final int initialStars;
  final String initialComment;

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late int _stars = widget.initialStars;
  late final _comment = TextEditingController(text: widget.initialComment);

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.subtitle != null) ...[
              Text(widget.subtitle!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
            ],
            StarInput(value: _stars, onChanged: (v) => setState(() => _stars = v)),
            const SizedBox(height: 16),
            TextField(
              controller: _comment,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(labelText: 'Nhận xét (không bắt buộc)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(
          onPressed: _stars == 0 ? null : () => Navigator.pop(context, (stars: _stars, comment: _comment.text.trim())),
          child: const Text('Gửi đánh giá'),
        ),
      ],
    );
  }
}
