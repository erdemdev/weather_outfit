import 'package:flutter/material.dart';

enum HarmonyType {
  complementary,   // Tamamlayıcı
  analogous,       // Benzer
  triadic,         // Üçlü
  splitComplementary, // Bölünmüş tamamlayıcı
  monochromatic,   // Tek renkli
}

class ColorHarmony {
  /// İki renk arasındaki uyum skoru (0.0 - 1.0)
  static double score(Color a, Color b) {
    final hslA = HSLColor.fromColor(a);
    final hslB = HSLColor.fromColor(b);
    final hueDiff = _hueDist(hslA.hue, hslB.hue);

    // Complementary (180°) — yüksek uyum
    if ((hueDiff - 180).abs() < 20) return 0.9;
    // Triadic (120°)
    if ((hueDiff - 120).abs() < 15 || (hueDiff - 240).abs() < 15) return 0.85;
    // Split complementary (150-210°)
    if (hueDiff > 140 && hueDiff < 220) return 0.8;
    // Analogous (30°)
    if (hueDiff < 35) return 0.75;
    // Monochromatic
    if (hueDiff < 10) return 0.95;
    // Clash zone (60-80°)
    if (hueDiff > 55 && hueDiff < 85) return 0.3;

    return 0.5;
  }

  /// Kombin puanı — tüm renklerin birbirleriyle uyumu
  static double outfitScore(List<Color> colors) {
    if (colors.length < 2) return 1.0;
    double total = 0;
    int count = 0;
    for (var i = 0; i < colors.length; i++) {
      for (var j = i + 1; j < colors.length; j++) {
        total += score(colors[i], colors[j]);
        count++;
      }
    }
    return count > 0 ? total / count : 1.0;
  }

  /// Harmonik renk önerileri üret
  static List<Color> suggestions(Color base, HarmonyType type) {
    final hsl = HSLColor.fromColor(base);
    switch (type) {
      case HarmonyType.complementary:
        return [
          hsl.withHue((hsl.hue + 180) % 360).toColor(),
        ];
      case HarmonyType.analogous:
        return [
          hsl.withHue((hsl.hue + 30) % 360).toColor(),
          hsl.withHue((hsl.hue - 30 + 360) % 360).toColor(),
        ];
      case HarmonyType.triadic:
        return [
          hsl.withHue((hsl.hue + 120) % 360).toColor(),
          hsl.withHue((hsl.hue + 240) % 360).toColor(),
        ];
      case HarmonyType.splitComplementary:
        return [
          hsl.withHue((hsl.hue + 150) % 360).toColor(),
          hsl.withHue((hsl.hue + 210) % 360).toColor(),
        ];
      case HarmonyType.monochromatic:
        return [
          hsl.withLightness((hsl.lightness + 0.2).clamp(0, 1)).toColor(),
          hsl.withLightness((hsl.lightness - 0.2).clamp(0, 1)).toColor(),
        ];
    }
  }

  /// Uyum etiketi
  static String label(double score, {bool isEN = false}) {
    if (score >= 0.85) return isEN ? 'Perfect Match! 🎨' : 'Mükemmel Uyum! 🎨';
    if (score >= 0.7) return isEN ? 'Great Combo ✨' : 'Harika Kombin ✨';
    if (score >= 0.5) return isEN ? 'Nice Mix 👍' : 'İyi Kombinasyon 👍';
    if (score >= 0.35) return isEN ? 'Could be better' : 'Geliştirilebilir';
    return isEN ? 'Clashing Colors ⚠️' : 'Çarpışan Renkler ⚠️';
  }

  /// Uyum rengi
  static Color indicator(double score) {
    if (score >= 0.7) return const Color(0xFF4CAF50);
    if (score >= 0.5) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  static double _hueDist(double a, double b) {
    final d = (a - b).abs();
    return d > 180 ? 360 - d : d;
  }
}
