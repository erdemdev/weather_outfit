import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'color_harmony_service.dart';

/// Data passed to the background isolate for color extraction.
class _ImageAnalysisInput {
  final String filePath;
  const _ImageAnalysisInput(this.filePath);
}

class OutfitScore {
  final int totalScore;
  final int colorHarmonyScore;
  final int seasonMatchScore;
  final int completenessScore;
  final int styleScore;
  final List<Color> dominantColors;
  final String verdict;
  final String verdictEN;
  final List<String> tips;
  final List<String> tipsEN;

  const OutfitScore({
    required this.totalScore,
    required this.colorHarmonyScore,
    required this.seasonMatchScore,
    required this.completenessScore,
    required this.styleScore,
    required this.dominantColors,
    required this.verdict,
    required this.verdictEN,
    required this.tips,
    required this.tipsEN,
  });

  String get grade {
    if (totalScore >= 90) return 'S';
    if (totalScore >= 80) return 'A';
    if (totalScore >= 70) return 'B';
    if (totalScore >= 60) return 'C';
    if (totalScore >= 50) return 'D';
    return 'F';
  }

  Color get gradeColor {
    if (totalScore >= 90) return const Color(0xFF4CAF50);
    if (totalScore >= 80) return const Color(0xFF8BC34A);
    if (totalScore >= 70) return const Color(0xFFFFC107);
    if (totalScore >= 60) return const Color(0xFFFF9800);
    if (totalScore >= 50) return const Color(0xFFFF5722);
    return const Color(0xFFF44336);
  }
}

class OutfitScoringService {
  static Future<OutfitScore> scoreOutfit({
    required String photoPath,
    required List<String> categories,
    double? currentTemp,
    String? currentCondition,
  }) async {
    final dominantColors = await _extractDominantColors(photoPath);

    final colorHarmony = _scoreColorHarmony(dominantColors);
    final seasonMatch = _scoreSeasonMatch(dominantColors, currentTemp, currentCondition);
    final completeness = _scoreCompleteness(categories);
    final style = _scoreStyle(dominantColors, categories);

    final total = colorHarmony + seasonMatch + completeness + style;

    final tips = <String>[];
    final tipsEN = <String>[];
    _generateTips(
      colorHarmony: colorHarmony,
      seasonMatch: seasonMatch,
      completeness: completeness,
      style: style,
      categories: categories,
      tips: tips,
      tipsEN: tipsEN,
    );

    return OutfitScore(
      totalScore: total.clamp(0, 100),
      colorHarmonyScore: colorHarmony,
      seasonMatchScore: seasonMatch,
      completenessScore: completeness,
      styleScore: style,
      dominantColors: dominantColors,
      verdict: _getVerdict(total),
      verdictEN: _getVerdictEN(total),
      tips: tips,
      tipsEN: tipsEN,
    );
  }

  /// Reads file AND extracts colors entirely in a background isolate.
  /// Zero main-thread I/O — file read happens inside the isolate.
  static Future<List<Color>> _extractDominantColors(String path) async {
    try {
      final colorValues = await compute(
        _analyzeImageFile,
        _ImageAnalysisInput(path),
      );

      return colorValues
          .map((v) => Color.fromARGB(
              255, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF))
          .toList();
    } catch (_) {
      return _fallbackColors();
    }
  }

  /// Runs entirely in background isolate: reads file + analyzes bytes.
  static List<int> _analyzeImageFile(_ImageAnalysisInput input) {
    try {
      final file = File(input.filePath);
      if (!file.existsSync()) return _fallbackColorValues();

      final bytes = file.readAsBytesSync();
      if (bytes.length < 100) return _fallbackColorValues();

      final colorCounts = <int, int>{};

      // Skip file headers (first 512 bytes for JPEG/PNG metadata)
      final start = bytes.length > 512 ? 512 : 0;
      // Sample ~2000 triplets across the file
      final step = ((bytes.length - start) ~/ 2000).clamp(3, 500);

      for (var i = start; i < bytes.length - 2; i += step) {
        final r = bytes[i];
        final g = bytes[i + 1];
        final b = bytes[i + 2];

        // Aggressive quantization for compressed byte patterns
        final qr = (r ~/ 48) * 48;
        final qg = (g ~/ 48) * 48;
        final qb = (b ~/ 48) * 48;

        // Skip near-white and near-black
        if (qr > 200 && qg > 200 && qb > 200) continue;
        if (qr < 30 && qg < 30 && qb < 30) continue;

        // Skip very low saturation grays
        final maxC = qr > qg ? (qr > qb ? qr : qb) : (qg > qb ? qg : qb);
        final minC = qr < qg ? (qr < qb ? qr : qb) : (qg < qb ? qg : qb);
        if (maxC - minC < 20) continue;

        final key = (qr << 16) | (qg << 8) | qb;
        colorCounts[key] = (colorCounts[key] ?? 0) + 1;
      }

      if (colorCounts.isEmpty) return _fallbackColorValues();

      final sorted = colorCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(5).map((e) => e.key).toList();
    } catch (_) {
      return _fallbackColorValues();
    }
  }

  static List<int> _fallbackColorValues() => [0x607D8B, 0x455A64, 0x78909C];

  static List<Color> _fallbackColors() => const [
        Color(0xFF607D8B),
        Color(0xFF455A64),
        Color(0xFF78909C),
      ];

  static int _scoreColorHarmony(List<Color> colors) {
    if (colors.length < 2) return 15;
    final score = ColorHarmony.outfitScore(colors);
    return (score * 25).round().clamp(0, 25);
  }

  static int _scoreSeasonMatch(
      List<Color> colors, double? temp, String? condition) {
    if (temp == null) return 18;
    int score = 15;
    final avgSat = _averageSaturation(colors);
    final avgLight = _averageLightness(colors);
    final avgHue = _averageHue(colors);

    if (temp < 5) {
      if (avgLight < 0.5) score += 4;
      if (avgSat < 0.6) score += 3;
      if (avgHue > 0 && avgHue < 60) score += 3;
    } else if (temp < 15) {
      if (avgSat > 0.3 && avgSat < 0.7) score += 4;
      if (avgLight > 0.3 && avgLight < 0.7) score += 3;
      score += 3;
    } else if (temp < 25) {
      score += 5;
      if (avgSat > 0.3) score += 3;
    } else {
      if (avgLight > 0.5) score += 4;
      if (avgSat > 0.4) score += 3;
      score += 3;
    }

    if (condition != null &&
        (condition.contains('rain') || condition.contains('storm'))) {
      if (avgLight < 0.5) score += 2;
    }

    return score.clamp(0, 25);
  }

  static int _scoreCompleteness(List<String> categories) {
    if (categories.isEmpty) return 10;
    int score = 0;
    final cats = categories.map((c) => c.toLowerCase()).toSet();

    if (cats.any((c) => c.contains('üst') || c.contains('top'))) score += 7;
    if (cats.any((c) => c.contains('alt') || c.contains('bottom'))) score += 7;
    if (cats.any((c) => c.contains('ayak') || c.contains('shoe'))) score += 5;
    if (cats.any((c) => c.contains('dış') || c.contains('outer'))) score += 3;
    if (cats.any((c) => c.contains('aksesuar') || c.contains('accessor'))) {
      score += 3;
    }

    return score.clamp(0, 25);
  }

  static int _scoreStyle(List<Color> colors, List<String> categories) {
    int score = 12;
    if (categories.toSet().length >= 3) score += 4;
    if (categories.toSet().length >= 4) score += 3;
    if (colors.length >= 2 && colors.length <= 4) score += 4;
    if (colors.length == 1) score += 1;

    final neutralCount = colors.where((c) {
      final hsl = HSLColor.fromColor(c);
      return hsl.saturation < 0.2;
    }).length;
    if (neutralCount > 0 && neutralCount <= colors.length ~/ 2 + 1) {
      score += 2;
    }

    return score.clamp(0, 25);
  }

  static double _averageHue(List<Color> colors) {
    if (colors.isEmpty) return 0;
    return colors.map((c) => HSLColor.fromColor(c).hue).reduce((a, b) => a + b) /
        colors.length;
  }

  static double _averageSaturation(List<Color> colors) {
    if (colors.isEmpty) return 0;
    return colors
            .map((c) => HSLColor.fromColor(c).saturation)
            .reduce((a, b) => a + b) /
        colors.length;
  }

  static double _averageLightness(List<Color> colors) {
    if (colors.isEmpty) return 0.5;
    return colors
            .map((c) => HSLColor.fromColor(c).lightness)
            .reduce((a, b) => a + b) /
        colors.length;
  }

  static void _generateTips({
    required int colorHarmony,
    required int seasonMatch,
    required int completeness,
    required int style,
    required List<String> categories,
    required List<String> tips,
    required List<String> tipsEN,
  }) {
    if (colorHarmony < 15) {
      tips.add('Renk uyumunu artırmak için benzer tonları tercih et.');
      tipsEN.add('Try using similar tones to improve color harmony.');
    }
    if (colorHarmony >= 20) {
      tips.add('Renk uyumun harika! Renkler birbirini çok iyi tamamlıyor.');
      tipsEN.add('Great color harmony! Colors complement each other well.');
    }
    if (seasonMatch < 15) {
      tips.add('Mevsime daha uygun renkler seçmeyi dene.');
      tipsEN.add('Try picking colors that better match the season.');
    }
    if (completeness < 15) {
      tips.add('Kombini tamamlamak için eksik parçaları ekle (üst, alt, ayakkabı).');
      tipsEN.add('Add missing pieces to complete the outfit (top, bottom, shoes).');
    }
    if (completeness >= 20) {
      tips.add('Kombin çok eksiksiz, tüm temel parçalar mevcut!');
      tipsEN.add('Very complete outfit — all essential pieces are there!');
    }
    if (style < 15) {
      tips.add('Daha fazla çeşitlilik eklemek stili yükseltir.');
      tipsEN.add('Adding more variety can elevate the style.');
    }
    if (style >= 20) {
      tips.add('Stil puanın çok yüksek, harika bir kombin!');
      tipsEN.add('Your style score is excellent — great outfit!');
    }
    if (tips.isEmpty) {
      tips.add('Güzel bir kombin! Aksesuar ekleyerek daha da tamamlayabilirsin.');
      tipsEN.add('Nice outfit! You can elevate it further with accessories.');
    }
  }

  static String _getVerdict(int total) {
    if (total >= 90) return 'Muhteşem! Stilist gibisin! 🌟';
    if (total >= 80) return 'Çok şık bir kombin! 👏';
    if (total >= 70) return 'Güzel görünüyor, küçük dokunuşlarla mükemmel olur! ✨';
    if (total >= 60) return 'İyi bir başlangıç, biraz daha uyum yakalar! 👌';
    if (total >= 50) return 'Fena değil, ama geliştirilebilir. 🤔';
    return 'Yeniden düzenlemen önerilir. 💪';
  }

  static String _getVerdictEN(int total) {
    if (total >= 90) return 'Stunning! You look like a stylist! 🌟';
    if (total >= 80) return 'Very stylish outfit! 👏';
    if (total >= 70) return 'Looks good — small touches can make it perfect! ✨';
    if (total >= 60) return 'Good start, a bit more coordination would help! 👌';
    if (total >= 50) return 'Not bad, but there\'s room for improvement. 🤔';
    return 'A restyle is recommended. 💪';
  }
}
