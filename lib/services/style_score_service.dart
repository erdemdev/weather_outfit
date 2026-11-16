import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StyleBadge {
  final String id;
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String descTR;
  final String descEN;
  final int xpRequired;

  const StyleBadge({
    required this.id,
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.descTR,
    required this.descEN,
    required this.xpRequired,
  });
}

class StyleScoreService {
  static const _xpKey = 'style_xp';
  static const _actionsKey = 'style_actions';

  static const badges = [
    StyleBadge(id: 'newbie', emoji: '🌱', titleTR: 'Acemi Stilist', titleEN: 'Style Newbie', descTR: 'İlk adımını at', descEN: 'Take your first step', xpRequired: 0),
    StyleBadge(id: 'explorer', emoji: '🔍', titleTR: 'Stil Kaşifi', titleEN: 'Style Explorer', descTR: '50 XP kazan', descEN: 'Earn 50 XP', xpRequired: 50),
    StyleBadge(id: 'trendsetter', emoji: '🔥', titleTR: 'Trend Belirleyici', titleEN: 'Trendsetter', descTR: '150 XP kazan', descEN: 'Earn 150 XP', xpRequired: 150),
    StyleBadge(id: 'fashionista', emoji: '👗', titleTR: 'Fashionista', titleEN: 'Fashionista', descTR: '300 XP kazan', descEN: 'Earn 300 XP', xpRequired: 300),
    StyleBadge(id: 'icon', emoji: '⭐', titleTR: 'Stil İkonu', titleEN: 'Style Icon', descTR: '500 XP kazan', descEN: 'Earn 500 XP', xpRequired: 500),
    StyleBadge(id: 'legend', emoji: '👑', titleTR: 'Moda Efsanesi', titleEN: 'Fashion Legend', descTR: '1000 XP kazan', descEN: 'Earn 1000 XP', xpRequired: 1000),
  ];

  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, current + amount);
  }

  static Future<int> getLevel() async {
    final xp = await getXP();
    if (xp >= 1000) return 6;
    if (xp >= 500) return 5;
    if (xp >= 300) return 4;
    if (xp >= 150) return 3;
    if (xp >= 50) return 2;
    return 1;
  }

  static Future<StyleBadge> getCurrentBadge() async {
    final level = await getLevel();
    return badges[level - 1];
  }

  static Future<StyleBadge?> getNextBadge() async {
    final level = await getLevel();
    if (level >= badges.length) return null;
    return badges[level];
  }

  static Future<double> getProgress() async {
    final xp = await getXP();
    final level = await getLevel();
    if (level >= badges.length) return 1.0;
    final current = badges[level - 1].xpRequired;
    final next = badges[level].xpRequired;
    return ((xp - current) / (next - current)).clamp(0.0, 1.0);
  }

  // XP rewards
  static Future<void> onOutfitViewed() async => addXP(2);
  static Future<void> onOutfitRated() async => addXP(5);
  static Future<void> onWardrobeItemAdded() async => addXP(3);
  static Future<void> onChallengeCompleted() async => addXP(10);
  static Future<void> onPhotoAdded() async => addXP(5);
  static Future<void> onSocialPost() async => addXP(8);

  static Future<Map<String, int>> getActionLog() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_actionsKey);
    if (data == null) return {};
    return (jsonDecode(data) as Map<String, dynamic>).cast<String, int>();
  }

  static Future<void> logAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await getActionLog();
    log[action] = (log[action] ?? 0) + 1;
    await prefs.setString(_actionsKey, jsonEncode(log));
  }
}
