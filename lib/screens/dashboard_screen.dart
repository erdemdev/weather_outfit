import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/history_service.dart';
import '../services/style_challenge_service.dart';
import '../services/care_reminder_service.dart';
import '../services/laundry_service.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherData? _weather;
  HistoryEntry? _lastOutfit;
  StyleChallenge? _todayChallenge;
  bool _challengeDone = false;
  int _streak = 0;
  int _overdueReminders = 0;
  int _dirtyLaundry = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final w = await WeatherService.getWeatherByGPS();
      setState(() => _weather = w);
    } catch (_) {
      setState(() => _weather = WeatherData.demo());
    }

    final history = await HistoryService.getHistory();
    final challenge = StyleChallengeService.getTodaysChallenge();
    final done = await StyleChallengeService.isTodayCompleted();
    final streak = await StyleChallengeService.getStreak();
    final overdue = await CareReminderService.getOverdueCount();
    final dirty = await LaundryService.getDirtyCount();

    setState(() {
      _lastOutfit = history.isNotEmpty ? history.first : null;
      _todayChallenge = challenge;
      _challengeDone = done;
      _streak = streak;
      _overdueReminders = overdue;
      _dirtyLaundry = dirty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Dashboard' : 'Özet Panel'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Weather card
            if (_weather != null) _buildWeatherCard(isDark, isEN),
            const SizedBox(height: 12),
            // Quick stats row
            Row(
              children: [
                Expanded(child: _miniCard('🔥', '$_streak', isEN ? 'Streak' : 'Seri', const Color(0xFFE8974A), isDark)),
                const SizedBox(width: 8),
                Expanded(child: _miniCard('🧺', '$_dirtyLaundry', isEN ? 'Dirty' : 'Kirli', Colors.orange, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _miniCard('⚠️', '$_overdueReminders', isEN ? 'Overdue' : 'Gecikmiş', Colors.red, isDark)),
              ],
            ),
            const SizedBox(height: 12),
            // Challenge card
            if (_todayChallenge != null) _buildChallengeCard(isDark, isEN),
            const SizedBox(height: 12),
            // Last outfit
            if (_lastOutfit != null) _buildLastOutfit(isDark, isEN),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(bool isDark, bool isEN) {
    final w = _weather!;
    final emoji = switch (w.condition.toLowerCase()) {
      'clear' => '☀️',
      'clouds' => '⛅',
      'rain' => '🌧️',
      'drizzle' => '🌦️',
      'thunderstorm' => '⛈️',
      'snow' => '❄️',
      _ => '🌤️',
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.city, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${w.temperature.round()}°C • ${w.description}', style: const TextStyle(color: Colors.white70)),
                Text(
                  '${isEN ? 'Feels' : 'Hissedilen'} ${w.feelsLike.round()}°C  •  💧${w.humidity}%',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String emoji, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(bool isDark, bool isEN) {
    final ch = _todayChallenge!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _challengeDone
            ? Colors.green.withOpacity(0.1)
            : (isDark ? const Color(0xFF1E3345) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: _challengeDone ? Border.all(color: Colors.green.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Text(ch.emojiTR, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEN ? "Today's Challenge" : 'Günün Challenge\'ı',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                ),
                Text(
                  isEN ? ch.titleEN : ch.titleTR,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
              ],
            ),
          ),
          if (_challengeDone)
            const Text('✅', style: TextStyle(fontSize: 24))
          else
            const Text('🎯', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildLastOutfit(bool isDark, bool isEN) {
    final e = _lastOutfit!;
    final condEmoji = switch (e.condition) {
      'clear' => '☀️',
      'clouds' => '⛅',
      'rain' => '🌧️',
      'snow' => '❄️',
      _ => '🌤️',
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(condEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEN ? 'Last Outfit' : 'Son Kombin',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                ),
                Text(e.outfitTitle, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                )),
                Text(
                  '${e.city} • ${e.temperature.round()}°C • ${e.date.day}.${e.date.month}.${e.date.year}',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ),
          if (e.rating != null)
            Text('⭐${e.rating}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
