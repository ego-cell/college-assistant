import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color accent = Color(0xFFF59E0B); // Amber Accent

  // Background & Surfaces - Light
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);

  // Background & Surfaces - Dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);

  // Text Colors - Light
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF64748B);

  // Task Category Colors
  static const Color categoryQuiz = Color(0xFFEF4444); // Red
  static const Color categoryAssignment = Color(0xFF3B82F6); // Blue
  static const Color categoryReport = Color(0xFF8B5CF6); // Purple
  static const Color categoryProject = Color(0xFF10B981); // Emerald Green
  static const Color categoryPersonal = Color(0xFFF97316); // Orange

  // Course Slot Type Colors
  static const Color typeLecture = Color(0xFF2563EB); // Royal Blue
  static const Color typeSection = Color(0xFF0D9488); // Teal
  static const Color typeLab = Color(0xFF9333EA); // Purple

  // Status Colors
  static const Color livePulse = Color(0xFF10B981); // Emerald Pulse
  static const Color urgent = Color(0xFFDC2626); // Crimson Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF16A34A); // Green
  static const Color info = Color(0xFF0284C7); // Sky Blue

  // Course Color Palette for random or customized slot colors
  static const List<Color> coursePalette = [
    Color(0xFF2563EB), // Blue
    Color(0xFF0D9488), // Teal
    Color(0xFF9333EA), // Purple
    Color(0xFFEA580C), // Orange
    Color(0xFF059669), // Emerald
    Color(0xFFE11D48), // Rose
    Color(0xFF4F46E5), // Indigo
    Color(0xFFD97706), // Amber
  ];
}
