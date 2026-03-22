import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF4F6AF5);
  static const Color accent = Color(0xFF7C3AED);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Map<String, Color> letterColors = {
    'A+': Color(0xFF059669),
    'A': Color(0xFF10B981),
    'B+': Color(0xFF3B82F6),
    'B': Color(0xFF6366F1),
    'C+': Color(0xFF8B5CF6),
    'C': Color(0xFFF59E0B),
    'D+': Color(0xFFF97316),
    'D': Color(0xFFEF4444),
    'F': Color(0xFF991B1B),
  };

  static Color letterColor(String letter) => letterColors[letter] ?? error;

  static Color gpaColor(double gpa) {
    if (gpa >= 3.6) return letterColors['A']!;
    if (gpa >= 3.2) return letterColors['B']!;
    if (gpa >= 2.5) return letterColors['C']!;
    if (gpa >= 1.8) return letterColors['D']!;
    return letterColors['F']!;
  }
}

class AppColorsData extends ThemeExtension<AppColorsData> {
  const AppColorsData({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.primaryLight,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color primaryLight;

  static const light = AppColorsData(
    background: Color(0xFFF8F9FC),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1D2E),
    textSecondary: Color(0xFF6B7299),
    textHint: Color(0xFFAEB5CC),
    divider: Color(0xFFE8ECF4),
    primaryLight: Color(0xFFEEF1FF),
  );

  static const dark = AppColorsData(
    background: Color(0xFF111318),
    surface: Color(0xFF1C1F28),

    textPrimary: Color(0xFFDFE3EE),
    textSecondary: Color(0xFF8D96B5),
    textHint: Color(0xFF545C7A),

    divider: Color(0xFF252A3B),
    primaryLight: Color(0xFF1A234E),
  );

  @override
  AppColorsData copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? primaryLight,
  }) => AppColorsData(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    divider: divider ?? this.divider,
    primaryLight: primaryLight ?? this.primaryLight,
  );

  @override
  AppColorsData lerp(AppColorsData? other, double t) {
    if (other == null) return this;
    return AppColorsData(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColorsData get colors =>
      Theme.of(this).extension<AppColorsData>() ?? AppColorsData.light;
}
