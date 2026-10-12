import 'package:flutter/material.dart';

/// Nút gọi nổi, rung ngang nhẹ để thu hút sự chú ý.
class VibratingFab extends StatefulWidget {
  const VibratingFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<VibratingFab> createState() => _VibratingFabState();
}

class _VibratingFabState extends State<VibratingFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _offset = Tween(begin: -3.0, end: 3.0).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (_, child) => Transform.translate(offset: Offset(_offset.value, 0), child: child),
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        tooltip: 'Liên hệ',
        onPressed: widget.onPressed,
        child: const Icon(Icons.phone_in_talk, color: Colors.blue, size: 35),
      ),
    );
  }
}
