import 'package:flutter/material.dart';
import '../services/style_score_service.dart';
import '../l10n/app_localizations.dart';

class StyleScoreScreen extends StatefulWidget {
  const StyleScoreScreen({super.key});

  @override
  State<StyleScoreScreen> createState() => _StyleScoreScreenState();
}

class _StyleScoreScreenState extends State<StyleScoreScreen> {
  int _xp = 0;
  int _level = 1;
  double _progress = 0;
  StyleBadge? _currentBadge;
  StyleBadge? _nextBadge;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final xp = await StyleScoreService.getXP();
    final level = await StyleScoreService.getLevel();
    final progress = await StyleScoreService.getProgress();
    final current = await StyleScoreService.getCurrentBadge();
    final next = await StyleScoreService.getNextBadge();
    setState(() {
      _xp = xp;
      _level = level;
      _progress = progress;
      _currentBadge = current;
      _nextBadge = next;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Style Score' : 'Stil Puanı'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // XP Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C6E8A), Color(0xFF1A4A5E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(_currentBadge?.emoji ?? '🌱', style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 8),
                      Text(
                        isEN ? (_currentBadge?.titleEN ?? 'Newbie') : (_currentBadge?.titleTR ?? 'Acemi'),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text('Level $_level', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 16),
                      // XP display
                      Text('$_xp XP', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      // Progress bar
                      if (_nextBadge != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEN
                              ? '${(_progress * 100).round()}% to ${_nextBadge!.titleEN}'
                              : '${_nextBadge!.titleTR} için %${(_progress * 100).round()}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ] else
                        Text(isEN ? 'Maximum level reached!' : 'Maksimum seviyeye ulaştın!', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // XP earning ways
                Text(
                  isEN ? 'Earn XP' : 'XP Kazan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 12),
                _buildXPRow('👕', isEN ? 'View outfit suggestion' : 'Kombin önerisine bak', '+2 XP', isDark),
                _buildXPRow('⭐', isEN ? 'Rate an outfit' : 'Kombin puanla', '+5 XP', isDark),
                _buildXPRow('📦', isEN ? 'Add wardrobe item' : 'Dolaba parça ekle', '+3 XP', isDark),
                _buildXPRow('🏆', isEN ? 'Complete challenge' : 'Meydan okuma tamamla', '+10 XP', isDark),
                _buildXPRow('📸', isEN ? 'Add photo' : 'Fotoğraf ekle', '+5 XP', isDark),
                _buildXPRow('📱', isEN ? 'Share on social feed' : 'Sosyal duvarla paylaş', '+8 XP', isDark),
                const SizedBox(height: 24),
                // All badges
                Text(
                  isEN ? 'All Badges' : 'Tüm Rozetler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: StyleScoreService.badges.map((badge) {
                    final unlocked = _xp >= badge.xpRequired;
                    return Container(
                      decoration: BoxDecoration(
                        color: unlocked
                            ? (isDark ? const Color(0xFF1B2A3D) : Colors.white)
                            : (isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                        border: unlocked ? Border.all(color: const Color(0xFF2C6E8A).withValues(alpha: 0.5)) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            unlocked ? badge.emoji : '🔒',
                            style: TextStyle(fontSize: 32, color: unlocked ? null : Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEN ? badge.titleEN : badge.titleTR,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: unlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          Text('${badge.xpRequired} XP', style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.black26)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildXPRow(String emoji, String label, String xp, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(xp, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50), fontSize: 13)),
        ),
      ),
    );
  }
}
