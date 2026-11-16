import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pastel ve açık renklerde okunabilir metin/arka plan üretir.
class ContrastUtils {
  ContrastUtils._();

  static bool isLight(Color color) => color.computeLuminance() > 0.5;

  static double _contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool _hasLowContrastOn(Color foreground, Color background) {
    return _contrastRatio(foreground, background) < 4.0;
  }

  /// Vurgu rengi üzerinde okunaklı etiket rengi.
  static Color accentText(Color accent, {required bool isDark}) {
    final surface = isDark ? const Color(0xFF1A2B35) : Colors.white;
    final fallback = isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1A2B35);
    if (_hasLowContrastOn(accent, surface) || isLight(accent)) {
      return fallback;
    }
    return isDark ? Color.lerp(accent, Colors.white, 0.2)! : accent;
  }

  static Color bodyText({required bool isDark}) =>
      isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937);

  static Color subtitleText({required bool isDark}) =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);

  static Color sectionTitle({required bool isDark}) =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1A2B35);

  static Color itemTileFill(Color itemColor, bool isDark) {
    if (isDark) {
      return isLight(itemColor)
          ? Colors.white.withValues(alpha: 0.1)
          : itemColor.withValues(alpha: 0.24);
    }
    return isLight(itemColor)
        ? itemColor.withValues(alpha: 0.22)
        : itemColor.withValues(alpha: 0.12);
  }

  static Color itemTileBorder(Color itemColor, bool isDark) {
    if (isDark) {
      return isLight(itemColor)
          ? Colors.white.withValues(alpha: 0.18)
          : itemColor.withValues(alpha: 0.5);
    }
    return isLight(itemColor)
        ? itemColor.withValues(alpha: 0.4)
        : itemColor.withValues(alpha: 0.3);
  }

  static Color itemNameColor(Color itemColor, bool isDark) {
    final background = isDark ? const Color(0xFF1A2B35) : Colors.white;
    final fallback = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1A2B35);
    if (_hasLowContrastOn(itemColor, background) || isLight(itemColor)) {
      return fallback;
    }
    return isDark ? Color.lerp(itemColor, Colors.white, 0.35)! : itemColor;
  }

  static Color itemCategoryColor(Color itemColor, bool isDark) {
    final background = isDark ? const Color(0xFF1A2B35) : Colors.white;
    final fallback = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151);
    if (_hasLowContrastOn(itemColor, background) || isLight(itemColor)) {
      return fallback;
    }
    return isDark ? Color.lerp(itemColor, Colors.white, 0.25)! : itemColor;
  }

  static Color itemCategoryBackground(Color itemColor, bool isDark) {
    if (isLight(itemColor) || _hasLowContrastOn(itemColor, Colors.white)) {
      return isDark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFF1A2B35).withValues(alpha: 0.08);
    }
    return itemColor.withValues(alpha: isDark ? 0.28 : 0.16);
  }
}
