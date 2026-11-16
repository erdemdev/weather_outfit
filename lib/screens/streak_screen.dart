import 'package:flutter/material.dart';
import '../services/streak_service.dart';
import '../l10n/app_localizations.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  StreakData? _streak;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final streak = await StreakService.recordVisit();
    setState(() => _streak = streak);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Daily Streak' : 'Günlük Seri'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _streak == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C6E8A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    StreakService.getStreakEmoji(_streak!.currentStreak),
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_streak!.currentStreak}',
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A2B35)),
                  ),
                  Text(
                    isEN ? 'Day Streak' : 'Günlük Seri',
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C6E8A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      StreakService.getStreakTitle(_streak!.currentStreak, isEN: isEN),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C6E8A)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(child: _statCard('🏆', isEN ? 'Longest Streak' : 'En Uzun Seri', '${_streak!.longestStreak} ${isEN ? 'days' : 'gün'}', isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('📅', isEN ? 'Total Days' : 'Toplam Gün', '${_streak!.totalDays}', isDark)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Milestones
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(isEN ? 'Milestones' : 'Kilometre Taşları',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                  ),
                  const SizedBox(height: 12),
                  ..._milestones(isEN).map((m) => _buildMilestone(m, isDark)),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String emoji, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _milestones(bool isEN) {
    return [
      {'days': 3, 'emoji': '✨', 'title': isEN ? '3-Day Start' : '3 Gün Başlangıç', 'reached': _streak!.longestStreak >= 3},
      {'days': 7, 'emoji': '🔥', 'title': isEN ? '1 Week Fire' : '1 Hafta Ateş', 'reached': _streak!.longestStreak >= 7},
      {'days': 14, 'emoji': '⭐', 'title': isEN ? '2 Weeks Star' : '2 Hafta Yıldız', 'reached': _streak!.longestStreak >= 14},
      {'days': 30, 'emoji': '🏆', 'title': isEN ? '1 Month Champion' : '1 Ay Şampiyon', 'reached': _streak!.longestStreak >= 30},
      {'days': 100, 'emoji': '💎', 'title': isEN ? '100 Days Diamond' : '100 Gün Elmas', 'reached': _streak!.longestStreak >= 100},
      {'days': 365, 'emoji': '👑', 'title': isEN ? '1 Year Legend' : '1 Yıl Efsane', 'reached': _streak!.longestStreak >= 365},
    ];
  }

  Widget _buildMilestone(Map<String, dynamic> m, bool isDark) {
    final reached = m['reached'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: reached
            ? const Color(0xFF2C6E8A).withOpacity(0.1)
            : (isDark ? const Color(0xFF1E3345) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: reached ? Border.all(color: const Color(0xFF2C6E8A).withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Text(m['emoji'], style: TextStyle(fontSize: 24, color: reached ? null : Colors.grey)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(m['title'], style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: reached
                  ? (isDark ? Colors.white : const Color(0xFF1A2B35))
                  : (isDark ? Colors.white38 : Colors.grey),
            )),
          ),
          Text('${m['days']} ${AppStrings.lang == 'en' ? 'days' : 'gün'}',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey)),
          const SizedBox(width: 8),
          Icon(
            reached ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: reached ? const Color(0xFF2C6E8A) : (isDark ? Colors.white24 : Colors.grey[300]),
            size: 22,
          ),
        ],
      ),
    );
  }
}
