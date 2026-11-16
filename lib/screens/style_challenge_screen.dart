import 'package:flutter/material.dart';
import '../services/style_challenge_service.dart';
import '../l10n/app_localizations.dart';

class StyleChallengeScreen extends StatefulWidget {
  const StyleChallengeScreen({super.key});

  @override
  State<StyleChallengeScreen> createState() => _StyleChallengeScreenState();
}

class _StyleChallengeScreenState extends State<StyleChallengeScreen> {
  StyleChallenge? _challenge;
  bool _todayDone = false;
  int _streak = 0;
  int _totalCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ch = StyleChallengeService.getTodaysChallenge();
    final done = await StyleChallengeService.isTodayCompleted();
    final streak = await StyleChallengeService.getStreak();
    final total = await StyleChallengeService.getTotalCompleted();
    setState(() {
      _challenge = ch;
      _todayDone = done;
      _streak = streak;
      _totalCompleted = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Style Challenge' : 'Stil Challenge'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _challenge == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats row
                Row(
                  children: [
                    Expanded(child: _statCard('🔥', '$_streak', isEN ? 'Streak' : 'Seri', const Color(0xFFE8974A), isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('🏆', '$_totalCompleted', isEN ? 'Completed' : 'Tamamlanan', const Color(0xFF6B4FCF), isDark)),
                  ],
                ),
                const SizedBox(height: 24),
                // Today's challenge
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: _todayDone
                        ? LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500])
                        : const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (_todayDone ? Colors.green : const Color(0xFF2C6E8A)).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _todayDone ? '✅' : _challenge!.emojiTR,
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEN ? "Today's Challenge" : 'Günün Challenge\'ı',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEN ? _challenge!.titleEN : _challenge!.titleTR,
                        style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEN ? _challenge!.descEN : _challenge!.descTR,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (!_todayDone)
                        ElevatedButton.icon(
                          onPressed: () async {
                            await StyleChallengeService.complete(_challenge!.id);
                            _loadData();
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(isEN ? 'Complete Challenge!' : 'Tamamla!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2C6E8A),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      else
                        Text(
                          isEN ? '🎉 Great job!' : '🎉 Harika iş!',
                          style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // All challenges preview
                Text(
                  isEN ? 'All Challenges' : 'Tüm Challenge\'lar',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 12),
                ...kChallenges.map((ch) {
                  final isCurrent = ch.id == _challenge!.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF2C6E8A).withValues(alpha: 0.1)
                          : (isDark ? const Color(0xFF1E3345) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent ? Border.all(color: const Color(0xFF2C6E8A)) : null,
                    ),
                    child: Row(
                      children: [
                        Text(ch.emojiTR, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          isEN ? ch.titleEN : ch.titleTR,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        )),
                        if (isCurrent) const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF2C6E8A)),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
