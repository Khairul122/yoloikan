import 'package:flutter/material.dart';
import 'app_colors_dark.dart';

/// Marine Intelligence design tokens.
///
/// Colors are exposed as getters that resolve to either the light or dark
/// palette depending on [setBrightness]. The app root updates this once per
/// theme change and forces a full rebuild so every screen picks up the
/// correct palette.
class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;

  static void setBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static bool get isDark => _brightness == Brightness.dark;

  // ── Light palette ─────────────────────────────────────────────────────
  static const Color _lightPrimary = Color(0xFF001E40);
  static const Color _lightPrimaryContainer = Color(0xFF003366);
  static const Color _lightSecondary = Color(0xFF006A6A);
  static const Color _lightSecondaryContainer = Color(0xFF90EFEF);
  static const Color _lightBackground = Color(0xFFF7F9FB);
  static const Color _lightSurface = Color(0xFFF7F9FB);
  static const Color _lightSurfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF191C1E);
  static const Color _lightOnSurfaceVariant = Color(0xFF43474F);
  static const Color _lightOutlineVariant = Color(0xFFC3C6D1);
  static const Color _lightError = Color(0xFFBA1A1A);
  static const Color _lightSuccess = Color(0xFF10B981);

  // ── Resolved tokens ───────────────────────────────────────────────────
  static Color get primary => isDark ? AppDarkColors.primary : _lightPrimary;
  static Color get primaryContainer =>
      isDark ? AppDarkColors.primaryContainer : _lightPrimaryContainer;

  static Color get secondary =>
      isDark ? AppDarkColors.secondary : _lightSecondary;
  static Color get secondaryContainer =>
      isDark ? AppDarkColors.secondaryContainer : _lightSecondaryContainer;

  static Color get background =>
      isDark ? AppDarkColors.background : _lightBackground;
  static Color get surface => isDark ? AppDarkColors.surface : _lightSurface;
  static Color get surfaceContainerLow =>
      isDark ? AppDarkColors.surfaceContainerLow : _lightSurfaceContainerLow;
  static Color get surfaceContainerLowest => isDark
      ? AppDarkColors.surfaceContainerLowest
      : _lightSurfaceContainerLowest;

  static Color get onSurface =>
      isDark ? AppDarkColors.onSurface : _lightOnSurface;
  static Color get onSurfaceVariant =>
      isDark ? AppDarkColors.onSurfaceVariant : _lightOnSurfaceVariant;
  static Color get outlineVariant =>
      isDark ? AppDarkColors.outlineVariant : _lightOutlineVariant;

  static Color get error => isDark ? AppDarkColors.error : _lightError;
  static Color get success => isDark ? AppDarkColors.success : _lightSuccess;

  // Backward-compatible aliases (existing widgets reuse these names)
  static Color get accent => secondary;
  static Color get textDark => onSurface;
  static Color get textSecondary => onSurfaceVariant;
  static Color get cardBg => surfaceContainerLowest;
  static Color get divider => outlineVariant;

  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
}
