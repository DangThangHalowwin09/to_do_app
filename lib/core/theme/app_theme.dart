import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_spacing.dart';

/// Theme sáng của toàn app. Các màn hình lấy màu/kiểu chữ qua `Theme.of(context)`.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.blue,
      onPrimary: Colors.white,
      secondary: AppColors.red,
      error: AppColors.urgent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      // Cỡ chữ nền 16px, dòng cao 1.5 cho dễ đọc.
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ).copyWith(
            bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
            bodyMedium: const TextStyle(fontSize: 15, height: 1.5),
            bodySmall: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
            titleMedium: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.35),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTap, AppSpacing.minTap),
          shape: shape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTap, AppSpacing.minTap),
          shape: shape,
          side: const BorderSide(color: AppColors.blue),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTap, AppSpacing.minTap),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.urgent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.urgent, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    );
  }
}
