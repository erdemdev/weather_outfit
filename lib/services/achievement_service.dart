import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String descTR;
  final String descEN;
  final int target;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.descTR,
    required this.descEN,
    required this.target,
  });
}

const kAchievements = [
  Achievement(id: 'first_outfit', emoji: '🎉', titleTR: 'İlk Kombin', titleEN: 'First Outfit', descTR: 'İlk kombini gör', descEN: 'See your first outfit', target: 1),
  Achievement(id: 'streak_3', emoji: '🔥', titleTR: '3 Gün Seri', titleEN: '3 Day Streak', descTR: '3 gün üst üste kullan', descEN: 'Use 3 days in a row', target: 3),
  Achievement(id: 'streak_7', emoji: '🔥', titleTR: '7 Gün Seri', titleEN: '7 Day Streak', descTR: '1 hafta üst üste kullan', descEN: 'Use for 1 week straight', target: 7),
  Achievement(id: 'streak_30', emoji: '🏆', titleTR: 'Ay Şampiyonu', titleEN: 'Month Champion', descTR: '30 gün üst üste kullan', descEN: '30 day streak', target: 30),
  Achievement(id: 'rate_5', emoji: '⭐', titleTR: 'Eleştirmen', titleEN: 'Critic', descTR: '5 kombini puanla', descEN: 'Rate 5 outfits', target: 5),
  Achievement(id: 'rate_20', emoji: '🌟', titleTR: 'Uzman Eleştirmen', titleEN: 'Expert Critic', descTR: '20 kombini puanla', descEN: 'Rate 20 outfits', target: 20),
  Achievement(id: 'wardrobe_10', emoji: '👕', titleTR: 'Mini Dolap', titleEN: 'Mini Wardrobe', descTR: 'Dolaba 10 kıyafet ekle', descEN: 'Add 10 items to wardrobe', target: 10),
  Achievement(id: 'wardrobe_30', emoji: '🧥', titleTR: 'Büyük Dolap', titleEN: 'Big Wardrobe', descTR: 'Dolaba 30 kıyafet ekle', descEN: 'Add 30 items to wardrobe', target: 30),
  Achievement(id: 'cities_5', emoji: '🌍', titleTR: 'Gezgin', titleEN: 'Traveler', descTR: '5 farklı şehir ara', descEN: 'Search 5 different cities', target: 5),
  Achievement(id: 'cities_10', emoji: '✈️', titleTR: 'Dünya Gezgini', titleEN: 'World Traveler', descTR: '10 farklı şehir ara', descEN: 'Search 10 cities', target: 10),
  Achievement(id: 'fav_3', emoji: '❤️', titleTR: 'Koleksiyoner', titleEN: 'Collector', descTR: '3 favori kombin kaydet', descEN: 'Save 3 favorite outfits', target: 3),
  Achievement(id: 'all_weather', emoji: '🌈', titleTR: 'Her Havada', titleEN: 'All Weather', descTR: '4 farklı hava durumunda kombin gör', descEN: 'See outfits in 4 weather types', target: 4),
  Achievement(id: 'night_owl', emoji: '🦉', titleTR: 'Gece Kuşu', titleEN: 'Night Owl', descTR: 'Gece 00-05 arası uygulamayı aç', descEN: 'Open app between 00-05', target: 1),
  Achievement(id: 'share_1', emoji: '📤', titleTR: 'Paylaşımcı', titleEN: 'Sharer', descTR: 'İlk kombini paylaş', descEN: 'Share your first outfit', target: 1),
];

class AchievementService {
  static const _progressKey = 'achievement_progress';
  static const _unlockedKey = 'achievement_unlocked';
  static const _citiesKey = 'achievement_cities';
  static const _weathersKey = 'achievement_weathers';

  static Future<Map<String, int>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  static Future<Set<String>> getUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_unlockedKey) ?? []).toSet();
  }

  static Future<List<String>> checkAndUnlock(String achievementId, int current) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = await getProgress();
    progress[achievementId] = current;
    await prefs.setString(_progressKey, jsonEncode(progress));

    final unlocked = (prefs.getStringList(_unlockedKey) ?? []).toSet();
    final newlyUnlocked = <String>[];

    for (final a in kAchievements) {
      if (unlocked.contains(a.id)) continue;
      final p = progress[a.id] ?? 0;
      if (p >= a.target) {
        unlocked.add(a.id);
        newlyUnlocked.add(a.id);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await prefs.setStringList(_unlockedKey, unlocked.toList());
    }
    return newlyUnlocked;
  }

  static Future<void> trackCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = (prefs.getStringList(_citiesKey) ?? []).toSet();
    cities.add(city.toLowerCase());
    await prefs.setStringList(_citiesKey, cities.toList());
    await checkAndUnlock('cities_5', cities.length);
    await checkAndUnlock('cities_10', cities.length);
  }

  static Future<void> trackWeather(String condition) async {
    final prefs = await SharedPreferences.getInstance();
    final weathers = (prefs.getStringList(_weathersKey) ?? []).toSet();
    weathers.add(condition);
    await prefs.setStringList(_weathersKey, weathers.toList());
    await checkAndUnlock('all_weather', weathers.length);
  }

  static Future<void> trackNightOwl() async {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5) {
      await checkAndUnlock('night_owl', 1);
    }
  }
}
