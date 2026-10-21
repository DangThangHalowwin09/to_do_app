import 'package:flutter/material.dart';

/// Dãy ảnh nhỏ; chạm để xem toàn màn hình (phóng to được).
class ImageThumbnails extends StatelessWidget {
  const ImageThumbnails({super.key, required this.urls, this.size = 72});

  final List<String> urls;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < urls.length; i++)
          Semantics(
            button: true,
            label: 'Xem ảnh ${i + 1}',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _ImageViewer(urls: urls, initialIndex: i)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  urls[i],
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: size,
                    height: size,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.urls, required this.initialIndex});

  final List<String> urls;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Ảnh đính kèm')),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: urls.length,
        itemBuilder: (_, i) => InteractiveViewer(
          maxScale: 5,
          child: Center(child: Image.network(urls[i], fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
