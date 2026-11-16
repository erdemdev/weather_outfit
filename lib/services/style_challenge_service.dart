import 'package:shared_preferences/shared_preferences.dart';

class StyleChallenge {
  final String id;
  final String emojiTR;
  final String titleTR;
  final String titleEN;
  final String descTR;
  final String descEN;
  final List<String> colors;

  const StyleChallenge({
    required this.id,
    required this.emojiTR,
    required this.titleTR,
    required this.titleEN,
    required this.descTR,
    required this.descEN,
    this.colors = const [],
  });
}

const kChallenges = [
  StyleChallenge(id: 'monochrome', emojiTR: '⬛', titleTR: 'Monokrom Gün', titleEN: 'Monochrome Day', descTR: 'Tek renk tonunda kombin yap', descEN: 'Create a single-tone outfit', colors: ['black', 'white', 'grey']),
  StyleChallenge(id: 'bold_color', emojiTR: '🔴', titleTR: 'Cesur Renk', titleEN: 'Bold Color', descTR: 'Parlak bir ana renk kullan', descEN: 'Use a bold main color', colors: ['red', 'yellow', 'orange']),
  StyleChallenge(id: 'layers', emojiTR: '🧅', titleTR: 'Katmanlı Stil', titleEN: 'Layered Style', descTR: 'En az 3 katman giy', descEN: 'Wear at least 3 layers'),
  StyleChallenge(id: 'retro', emojiTR: '🕺', titleTR: 'Retro Gün', titleEN: 'Retro Day', descTR: 'Vintage veya retro parçalar kullan', descEN: 'Use vintage or retro pieces'),
  StyleChallenge(id: 'sporty', emojiTR: '🏃', titleTR: 'Spor Şık', titleEN: 'Sporty Chic', descTR: 'Spor parçaları şık kombinle', descEN: 'Mix sporty with chic pieces'),
  StyleChallenge(id: 'earth_tones', emojiTR: '🤎', titleTR: 'Toprak Tonları', titleEN: 'Earth Tones', descTR: 'Kahve, bej, yeşil tonları kullan', descEN: 'Use brown, beige, green tones', colors: ['brown', 'beige', 'olive']),
  StyleChallenge(id: 'denim', emojiTR: '👖', titleTR: 'Denim Günü', titleEN: 'Denim Day', descTR: 'Kot parçaları ön plana çıkar', descEN: 'Feature denim pieces'),
  StyleChallenge(id: 'minimalist', emojiTR: '✨', titleTR: 'Minimalist', titleEN: 'Minimalist', descTR: 'Maksimum 4 parça, sade renkler', descEN: 'Max 4 pieces, simple colors'),
  StyleChallenge(id: 'pattern_mix', emojiTR: '🎭', titleTR: 'Desen Karışımı', titleEN: 'Pattern Mix', descTR: 'Farklı desenleri cesurca karıştır', descEN: 'Mix different patterns boldly'),
  StyleChallenge(id: 'all_black', emojiTR: '🖤', titleTR: 'Total Black', titleEN: 'Total Black', descTR: 'Tamamen siyah kombin oluştur', descEN: 'Create an all-black outfit'),
  StyleChallenge(id: 'pastel', emojiTR: '🩷', titleTR: 'Pastel Rüya', titleEN: 'Pastel Dream', descTR: 'Pastel renklerle kombin yap', descEN: 'Style with pastel colors', colors: ['pink', 'lavender', 'mint']),
  StyleChallenge(id: 'accessory', emojiTR: '💎', titleTR: 'Aksesuar Odaklı', titleEN: 'Accessory Focus', descTR: 'Aksesuarlarla fark yarat', descEN: 'Make a statement with accessories'),
  StyleChallenge(id: 'comfort', emojiTR: '🛋️', titleTR: 'Rahat Gün', titleEN: 'Comfort Day', descTR: 'En rahat kıyafetlerini giy', descEN: 'Wear your comfiest clothes'),
  StyleChallenge(id: 'color_block', emojiTR: '🟦', titleTR: 'Renk Bloklama', titleEN: 'Color Blocking', descTR: 'Kontrast renk blokları kullan', descEN: 'Use contrasting color blocks'),
];

class StyleChallengeService {
  static const _completedKey = 'style_challenges_completed';
  static const _streakKey = 'challenge_streak';
  static const _lastDateKey = 'challenge_last_date';

  /// Bugünün challenge'ını al (günün tarihine göre)
  static StyleChallenge getTodaysChallenge() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return kChallenges[dayOfYear % kChallenges.length];
  }

  /// Challenge tamamla
  static Future<void> complete(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];
    final today = _dateKey(DateTime.now());

    if (!completed.contains('$challengeId:$today')) {
      completed.add('$challengeId:$today');
      await prefs.setStringList(_completedKey, completed);
    }

    // Streak hesapla
    final lastDate = prefs.getString(_lastDateKey);
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastDate == yesterday) {
      streak++;
    } else if (lastDate != today) {
      streak = 1;
    }
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastDateKey, today);
  }

  /// Bugün tamamlandı mı?
  static Future<bool> isTodayCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];
    final today = _dateKey(DateTime.now());
    final challenge = getTodaysChallenge();
    return completed.contains('${challenge.id}:$today');
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<int> getTotalCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedKey) ?? []).length;
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
