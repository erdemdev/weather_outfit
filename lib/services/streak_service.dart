import 'package:shared_preferences/shared_preferences.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalDays;
  final String lastDate;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
    required this.lastDate,
  });
}

class StreakService {
  static const _streakKey = 'daily_streak';
  static const _longestKey = 'longest_streak';
  static const _totalKey = 'total_days';
  static const _lastDateKey = 'last_streak_date';

  static Future<StreakData> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return StreakData(
      currentStreak: prefs.getInt(_streakKey) ?? 0,
      longestStreak: prefs.getInt(_longestKey) ?? 0,
      totalDays: prefs.getInt(_totalKey) ?? 0,
      lastDate: prefs.getString(_lastDateKey) ?? '',
    );
  }

  static Future<StreakData> recordVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDate = prefs.getString(_lastDateKey) ?? '';

    if (lastDate == todayStr) {
      return getStreak();
    }

    int streak = prefs.getInt(_streakKey) ?? 0;
    int longest = prefs.getInt(_longestKey) ?? 0;
    int total = prefs.getInt(_totalKey) ?? 0;

    if (lastDate.isNotEmpty) {
      final last = DateTime.parse(lastDate);
      final diff = now.difference(last).inDays;
      if (diff == 1) {
        streak++;
      } else {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    total++;
    if (streak > longest) longest = streak;

    await prefs.setInt(_streakKey, streak);
    await prefs.setInt(_longestKey, longest);
    await prefs.setInt(_totalKey, total);
    await prefs.setString(_lastDateKey, todayStr);

    return StreakData(
      currentStreak: streak,
      longestStreak: longest,
      totalDays: total,
      lastDate: todayStr,
    );
  }

  static String getStreakEmoji(int streak) {
    if (streak >= 365) return '👑';
    if (streak >= 100) return '💎';
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '✨';
    return '🌱';
  }

  static String getStreakTitle(int streak, {bool isEN = false}) {
    if (streak >= 365) return isEN ? 'Legendary!' : 'Efsane!';
    if (streak >= 100) return isEN ? 'Diamond' : 'Elmas';
    if (streak >= 30) return isEN ? 'Champion' : 'Şampiyon';
    if (streak >= 14) return isEN ? 'Star' : 'Yıldız';
    if (streak >= 7) return isEN ? 'On Fire' : 'Ateştesin';
    if (streak >= 3) return isEN ? 'Growing' : 'Büyüyorsun';
    return isEN ? 'Beginner' : 'Başlangıç';
  }
}
