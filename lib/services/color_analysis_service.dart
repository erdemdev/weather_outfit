import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorSeason {
  final String id;
  final String emoji;
  final String nameTR;
  final String nameEN;
  final String descTR;
  final String descEN;
  final List<Color> palette;
  final List<Color> avoid;

  const ColorSeason({
    required this.id,
    required this.emoji,
    required this.nameTR,
    required this.nameEN,
    required this.descTR,
    required this.descEN,
    required this.palette,
    required this.avoid,
  });
}

class ColorAnalysisService {
  static const _key = 'color_season_result';

  static const seasons = [
    ColorSeason(
      id: 'spring',
      emoji: '🌸',
      nameTR: 'İlkbahar',
      nameEN: 'Spring',
      descTR: 'Sıcak ve canlı renkler sana çok yakışır! Altın sarısı, mercan, turkuaz tonları ideal.',
      descEN: 'Warm and vivid colors suit you! Golden, coral, turquoise tones are ideal.',
      palette: [Color(0xFFFF7F50), Color(0xFFFFD700), Color(0xFF40E0D0), Color(0xFF98FB98), Color(0xFFFF69B4), Color(0xFFFFA07A)],
      avoid: [Color(0xFF000000), Color(0xFF808080), Color(0xFF4B0082)],
    ),
    ColorSeason(
      id: 'summer',
      emoji: '☀️',
      nameTR: 'Yaz',
      nameEN: 'Summer',
      descTR: 'Soğuk ve yumuşak renkler sana yakışır! Lavanta, gül kurusu, açık mavi ideal.',
      descEN: 'Cool and soft colors suit you! Lavender, dusty rose, light blue are ideal.',
      palette: [Color(0xFFE6E6FA), Color(0xFFBC8F8F), Color(0xFF87CEEB), Color(0xFFC0C0C0), Color(0xFFB0C4DE), Color(0xFFDDA0DD)],
      avoid: [Color(0xFFFF4500), Color(0xFFFF8C00), Color(0xFF8B0000)],
    ),
    ColorSeason(
      id: 'autumn',
      emoji: '🍂',
      nameTR: 'Sonbahar',
      nameEN: 'Autumn',
      descTR: 'Sıcak ve derin renkler ideal! Toprak tonları, hardal, zeytin yeşili, turuncu.',
      descEN: 'Warm and deep colors are ideal! Earth tones, mustard, olive green, orange.',
      palette: [Color(0xFFDAA520), Color(0xFF8B4513), Color(0xFF556B2F), Color(0xFFD2691E), Color(0xFFCD853F), Color(0xFFA0522D)],
      avoid: [Color(0xFF00BFFF), Color(0xFFFF69B4), Color(0xFF7FFFD4)],
    ),
    ColorSeason(
      id: 'winter',
      emoji: '❄️',
      nameTR: 'Kış',
      nameEN: 'Winter',
      descTR: 'Soğuk ve keskin kontrastlar sana yakışır! Saf beyaz, siyah, kraliyet mavisi, koyu kırmızı.',
      descEN: 'Cool, sharp contrasts suit you! Pure white, black, royal blue, deep red.',
      palette: [Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFF4169E1), Color(0xFF8B0000), Color(0xFF4B0082), Color(0xFFC0C0C0)],
      avoid: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFDEB887)],
    ),
  ];

  /// Quiz questions to determine color season
  static const questions = [
    {
      'tr': 'Cilt tonun nasıl?',
      'en': 'What is your skin tone?',
      'options': [
        {'tr': 'Açık / Pembe tonlu', 'en': 'Light / Pink undertone', 'spring': 0, 'summer': 2, 'autumn': 0, 'winter': 2},
        {'tr': 'Açık / Altın tonlu', 'en': 'Light / Golden undertone', 'spring': 2, 'summer': 0, 'autumn': 1, 'winter': 0},
        {'tr': 'Orta / Zeytin tonlu', 'en': 'Medium / Olive undertone', 'spring': 0, 'summer': 1, 'autumn': 2, 'winter': 1},
        {'tr': 'Koyu / Sıcak tonlu', 'en': 'Dark / Warm undertone', 'spring': 1, 'summer': 0, 'autumn': 2, 'winter': 1},
        {'tr': 'Koyu / Soğuk tonlu', 'en': 'Dark / Cool undertone', 'spring': 0, 'summer': 1, 'autumn': 0, 'winter': 2},
      ],
    },
    {
      'tr': 'Saç rengin ne?',
      'en': 'What is your hair color?',
      'options': [
        {'tr': 'Sarışın / Bal', 'en': 'Blonde / Honey', 'spring': 2, 'summer': 1, 'autumn': 1, 'winter': 0},
        {'tr': 'Kızıl / Bakır', 'en': 'Red / Copper', 'spring': 1, 'summer': 0, 'autumn': 2, 'winter': 0},
        {'tr': 'Açık kahve', 'en': 'Light brown', 'spring': 1, 'summer': 2, 'autumn': 1, 'winter': 0},
        {'tr': 'Koyu kahve', 'en': 'Dark brown', 'spring': 0, 'summer': 1, 'autumn': 1, 'winter': 1},
        {'tr': 'Siyah', 'en': 'Black', 'spring': 0, 'summer': 0, 'autumn': 0, 'winter': 2},
      ],
    },
    {
      'tr': 'Göz rengin ne?',
      'en': 'What is your eye color?',
      'options': [
        {'tr': 'Mavi', 'en': 'Blue', 'spring': 1, 'summer': 2, 'autumn': 0, 'winter': 1},
        {'tr': 'Yeşil', 'en': 'Green', 'spring': 2, 'summer': 1, 'autumn': 1, 'winter': 0},
        {'tr': 'Ela / Kahve', 'en': 'Hazel / Brown', 'spring': 1, 'summer': 0, 'autumn': 2, 'winter': 0},
        {'tr': 'Koyu kahve / Siyah', 'en': 'Dark brown / Black', 'spring': 0, 'summer': 0, 'autumn': 1, 'winter': 2},
      ],
    },
    {
      'tr': 'Hangi renk kıyafetlerde daha çok iltifat alırsın?',
      'en': 'In which colors do you receive more compliments?',
      'options': [
        {'tr': 'Parlak ve canlı renkler', 'en': 'Bright and vivid colors', 'spring': 2, 'summer': 0, 'autumn': 0, 'winter': 1},
        {'tr': 'Pastel ve yumuşak tonlar', 'en': 'Pastel and soft tones', 'spring': 1, 'summer': 2, 'autumn': 0, 'winter': 0},
        {'tr': 'Toprak tonları ve sıcak renkler', 'en': 'Earth tones and warm colors', 'spring': 0, 'summer': 0, 'autumn': 2, 'winter': 0},
        {'tr': 'Kontrastlı ve keskin renkler', 'en': 'Contrasting and sharp colors', 'spring': 0, 'summer': 0, 'autumn': 0, 'winter': 2},
      ],
    },
    {
      'tr': 'Güneşte cildin nasıl tepki verir?',
      'en': 'How does your skin react to sun?',
      'options': [
        {'tr': 'Kolay yanar, az bronzlaşır', 'en': 'Burns easily, tans little', 'spring': 1, 'summer': 2, 'autumn': 0, 'winter': 1},
        {'tr': 'Hafif yanar, sonra bronzlaşır', 'en': 'Burns slightly then tans', 'spring': 2, 'summer': 1, 'autumn': 1, 'winter': 0},
        {'tr': 'Kolay bronzlaşır', 'en': 'Tans easily', 'spring': 0, 'summer': 0, 'autumn': 2, 'winter': 1},
        {'tr': 'Çok az yanar, derin bronzlaşır', 'en': 'Rarely burns, tans deeply', 'spring': 0, 'summer': 0, 'autumn': 1, 'winter': 2},
      ],
    },
  ];

  /// Calculate season from quiz answers (list of option indices)
  static ColorSeason calculateSeason(List<int> answers) {
    final scores = {'spring': 0, 'summer': 0, 'autumn': 0, 'winter': 0};
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      final q = questions[i];
      final options = q['options'] as List;
      if (answers[i] < options.length) {
        final opt = options[answers[i]] as Map;
        scores['spring'] = scores['spring']! + (opt['spring'] as int);
        scores['summer'] = scores['summer']! + (opt['summer'] as int);
        scores['autumn'] = scores['autumn']! + (opt['autumn'] as int);
        scores['winter'] = scores['winter']! + (opt['winter'] as int);
      }
    }

    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return seasons.firstWhere((s) => s.id == sorted.first.key);
  }

  /// Save quiz result
  static Future<void> saveResult(String seasonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, seasonId);
  }

  /// Get saved result
  static Future<ColorSeason?> getSavedResult() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    if (id == null) return null;
    return seasons.where((s) => s.id == id).firstOrNull;
  }
}
