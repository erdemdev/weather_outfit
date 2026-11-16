import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../l10n/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, int> _progress = {};
  Set<String> _unlocked = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final progress = await AchievementService.getProgress();
    final unlocked = await AchievementService.getUnlocked();
    setState(() {
      _progress = progress;
      _unlocked = unlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final unlockedCount = _unlocked.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Achievements' : 'Başarımlar'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C6E8A).withOpacity(isDark ? 0.3 : 0.1),
                  const Color(0xFF3A8FA8).withOpacity(isDark ? 0.2 : 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  '🏆',
                  style: TextStyle(fontSize: unlockedCount > 0 ? 48 : 36),
                ),
                const SizedBox(height: 8),
                Text(
                  '$unlockedCount / ${kAchievements.length}',
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                Text(
                  isEN ? 'Achievements Unlocked' : 'Başarım Açıldı',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: kAchievements.isEmpty ? 0 : unlockedCount / kAchievements.length,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                    color: const Color(0xFF2C6E8A),
                  ),
                ),
              ],
            ),
          ),

          // Achievement list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kAchievements.length,
              itemBuilder: (ctx, i) {
                final a = kAchievements[i];
                final unlocked = _unlocked.contains(a.id);
                final current = _progress[a.id] ?? 0;
                final progressFraction = (current / a.target).clamp(0.0, 1.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? (isDark ? const Color(0xFF1A3A2A) : const Color(0xFFE8F5E9))
                        : (isDark ? const Color(0xFF1A2B35) : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: unlocked
                        ? Border.all(color: Colors.green.withOpacity(0.3))
                        : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Text(a.emoji, style: TextStyle(
                        fontSize: 32,
                        color: unlocked ? null : Colors.grey,
                      )),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isEN ? a.titleEN : a.titleTR,
                                    style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                                    ),
                                  ),
                                ),
                                if (unlocked)
                                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEN ? a.descEN : a.descTR,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white38 : Colors.grey[500],
                              ),
                            ),
                            if (!unlocked) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: progressFraction,
                                        minHeight: 4,
                                        backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                                        color: const Color(0xFF2C6E8A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$current/${a.target}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white38 : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
