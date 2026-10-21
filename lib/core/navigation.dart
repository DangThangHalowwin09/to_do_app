import 'package:flutter/material.dart';

/// Cho phép điều hướng từ ngoài cây widget (ví dụ khi bấm vào thông báo đẩy).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Hiện SnackBar từ ngoài cây widget (ví dụ thông báo đến khi đang mở bản web).
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
