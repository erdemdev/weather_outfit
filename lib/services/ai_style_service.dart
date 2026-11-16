import '../services/history_service.dart';
import '../services/wardrobe_service.dart';
import '../models/outfit_model.dart';
import '../models/weather_model.dart';
import 'package:flutter/material.dart';

class StyleInsight {
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String descTR;
  final String descEN;
  final double confidence;

  const StyleInsight({
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.descTR,
    required this.descEN,
    required this.confidence,
  });
}

class AiStyleService {
  /// Analyze history to learn user preferences
  static Future<List<StyleInsight>> analyzeStyle() async {
    final history = await HistoryService.getHistory();
    final wardrobe = await WardrobeService.getItems();
    final insights = <StyleInsight>[];

    if (history.isEmpty) {
      insights.add(const StyleInsight(
        emoji: '📊', titleTR: 'Veri Topleniyor', titleEN: 'Gathering Data',
        descTR: 'Daha fazla kombin kullanarak stil tercihlerin öğreniliyor',
        descEN: 'Using more outfits to learn your style preferences',
        confidence: 0.1,
      ));
      return insights;
    }

    // Preferred temperature ranges
    final highRated = history.where((h) => h.rating != null && h.rating! >= 4).toList();

    // Most used conditions
    final condCounts = <String, int>{};
    for (final h in history) {
      condCounts[h.condition] = (condCounts[h.condition] ?? 0) + 1;
    }
    final topCond = condCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (topCond.isNotEmpty) {
      final top = topCond.first;
      final condEmoji = switch (top.key) {
        'clear' => '☀️', 'clouds' => '⛅', 'rain' => '🌧️', 'snow' => '❄️', _ => '🌤️',
      };
      insights.add(StyleInsight(
        emoji: condEmoji,
        titleTR: 'En Aktif Havan', titleEN: 'Your Most Active Weather',
        descTR: '${top.key} havasında ${top.value} kez kombin oluşturdun',
        descEN: 'You created ${top.value} outfits in ${top.key} weather',
        confidence: top.value / history.length,
      ));
    }

    // Rating pattern
    if (highRated.length >= 2) {
      final avgHighTemp = highRated.map((h) => h.temperature).reduce((a, b) => a + b) / highRated.length;
      insights.add(StyleInsight(
        emoji: '⭐',
        titleTR: 'En Sevdiğin Sıcaklık', titleEN: 'Your Favorite Temperature',
        descTR: '${avgHighTemp.round()}°C civarında kombinlerini en çok beğeniyorsun',
        descEN: 'You rate outfits highest around ${avgHighTemp.round()}°C',
        confidence: highRated.length / history.length,
      ));
    }

    // Wardrobe balance
    final catCounts = <String, int>{};
    for (final w in wardrobe) {
      catCounts[w.category] = (catCounts[w.category] ?? 0) + 1;
    }
    final dominant = catCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (dominant.isNotEmpty) {
      insights.add(StyleInsight(
        emoji: '👕',
        titleTR: 'Dolap Ağırlığın', titleEN: 'Wardrobe Focus',
        descTR: 'En çok "${dominant.first.key}" kategorisinde parçan var (${dominant.first.value} adet)',
        descEN: 'Most items in "${dominant.first.key}" category (${dominant.first.value} items)',
        confidence: dominant.first.value / wardrobe.length,
      ));
    }

    // Usage frequency
    final daysActive = history.map((h) => '${h.date.year}-${h.date.month}-${h.date.day}').toSet().length;
    final totalDays = history.isNotEmpty
        ? DateTime.now().difference(history.last.date).inDays + 1
        : 1;
    final freq = (daysActive / totalDays).clamp(0.0, 1.0);
    insights.add(StyleInsight(
      emoji: '📅',
      titleTR: 'Kullanım Sıklığın', titleEN: 'Usage Frequency',
      descTR: 'Son $totalDays günde $daysActive gün aktifsin (${(freq * 100).round()}%)',
      descEN: 'Active $daysActive out of $totalDays days (${(freq * 100).round()}%)',
      confidence: freq,
    ));

    // Color preference from wardrobe
    if (wardrobe.length >= 3) {
      final colors = wardrobe.map((w) => HSLColor.fromColor(Color(w.colorValue))).toList();
      final warmCount = colors.where((c) => c.hue < 60 || c.hue > 300).length;
      final coolCount = colors.where((c) => c.hue >= 150 && c.hue <= 270).length;

      if (warmCount > coolCount) {
        insights.add(StyleInsight(
          emoji: '🔥', titleTR: 'Sıcak Tonlar Sever', titleEN: 'Warm Tones Lover',
          descTR: 'Dolabında sıcak tonlar ağırlıkta ($warmCount/${wardrobe.length})',
          descEN: 'Warm tones dominate your wardrobe ($warmCount/${wardrobe.length})',
          confidence: warmCount / wardrobe.length,
        ));
      } else if (coolCount > warmCount) {
        insights.add(StyleInsight(
          emoji: '❄️', titleTR: 'Soğuk Tonlar Sever', titleEN: 'Cool Tones Lover',
          descTR: 'Dolabında soğuk tonlar ağırlıkta ($coolCount/${wardrobe.length})',
          descEN: 'Cool tones dominate your wardrobe ($coolCount/${wardrobe.length})',
          confidence: coolCount / wardrobe.length,
        ));
      }
    }

    return insights;
  }

  /// Get personalized outfit suggestion based on learned preferences
  static Future<OutfitRecommendation> getSmartSuggestion(WeatherData weather) async {
    final history = await HistoryService.getHistory();
    final highRated = history.where((h) => h.rating != null && h.rating! >= 4).toList();

    // Use base engine but add AI twist
    final base = OutfitEngine.getRecommendation(weather);

    String aiTip;
    if (highRated.isNotEmpty) {
      final similar = highRated.where((h) =>
          (h.temperature - weather.temperature).abs() < 5 &&
          h.condition == weather.condition
      ).toList();
      if (similar.isNotEmpty) {
        aiTip = '🧠 Benzer havada "${similar.first.outfitTitle}" kombinini ⭐${similar.first.rating} puanladın';
      } else {
        aiTip = '🧠 ${highRated.length} yüksek puanlı kombinine göre bu öneri senin için ideal';
      }
    } else {
      aiTip = '🧠 Daha fazla kombin puanla, sana özel öneriler gelişsin';
    }

    return OutfitRecommendation(
      title: base.title,
      subtitle: '🧠 AI Öneri • ${base.subtitle}',
      tip: aiTip,
      items: base.items,
      alerts: base.alerts,
      primaryColor: base.primaryColor,
      secondaryColor: base.secondaryColor,
      weatherMood: base.weatherMood,
    );
  }
}
