import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF16213E);
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color accent = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF2D2D44);
  static const Color success = Color(0xFF10B981);
}

class AppStrings {
  static const String appName = 'WanaAnime';
  static const String tagline = 'Stream Anime, Anytime';
}

class AppDurations {
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
}
