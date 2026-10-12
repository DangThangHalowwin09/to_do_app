import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mở một trang web ngay trong app.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.url});

  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UBNA Manager'), centerTitle: true),
      body: WebViewWidget(controller: _controller),
    );
  }
}
