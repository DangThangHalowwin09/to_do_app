import 'package:flutter/material.dart';

class VibratingFab extends StatefulWidget {
  final VoidCallback onPressed;
  const VibratingFab({super.key, required this.onPressed});

  @override
  _VibratingFabState createState() => _VibratingFabState();
}

class _VibratingFabState extends State<VibratingFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true); // chạy lặp lại

    _animation = Tween(begin: -3.0, end: 3.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0), // rung ngang
          child: child,
        );
      },
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.phone_in_talk, color: Colors.blue, size: 35),
        onPressed: widget.onPressed,
      ),
    );
  }
}
