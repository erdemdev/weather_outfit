import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await HistoryService.getHistory();
    setState(() => _entries = entries);
  }

  // --- Statistics helpers ---
  Map<String, int> get _outfitFrequency {
    final map = <String, int>{};
    for (final e in _entries) {
      map[e.outfitTitle] = (map[e.outfitTitle] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get _conditionFrequency {
    final map = <String, int>{};
    for (final e in _entries) {
      map[e.condition] = (map[e.condition] ?? 0) + 1;
    }
    return map;
  }

  double get _averageRating {
    final rated = _entries.where((e) => e.rating != null).toList();
    if (rated.isEmpty) return 0;
    return rated.map((e) => e.rating!).reduce((a, b) => a + b) / rated.length;
  }

  double get _averageTemp {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.temperature).reduce((a, b) => a + b) / _entries.length;
  }

  int get _streakDays {
    if (_entries.isEmpty) return 0;
    int streak = 1;
    final sorted = List<HistoryEntry>.from(_entries)..sort((a, b) => b.date.compareTo(a.date));
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i - 1].date.difference(sorted[i].date).inDays;
      if (diff <= 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEN ? 'History' : 'Geçmiş'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: Icon(_showStats ? Icons.bar_chart_rounded : Icons.list_rounded),
              tooltip: _showStats ? (isEN ? 'List' : 'Liste') : (isEN ? 'Stats' : 'İstatistik'),
              onPressed: () => setState(() => _showStats = !_showStats),
            ),
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: isEN ? 'Clear' : 'Temizle',
              onPressed: () => _confirmClear(isDark, isEN),
            ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F9FC),
        child: _entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(
                      isEN ? 'No history yet' : 'Henüz geçmiş yok',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_showStats) ...[
                    _buildStatsCard(isDark, isEN),
                    const SizedBox(height: 12),
                    _buildTopOutfitsCard(isDark, isEN),
                    const SizedBox(height: 12),
                    _buildWeatherDistribution(isDark, isEN),
                    const SizedBox(height: 16),
                  ],
                  ...List.generate(_entries.length, (i) => _buildEntryCard(i, isDark)),
                ],
              ),
      ),
    );
  }

  void _confirmClear(bool isDark, bool isEN) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E3345) : Colors.white,
        title: Text(
          isEN ? 'Clear history?' : 'Geçmişi temizle?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEN ? 'Cancel' : 'İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HistoryService.clearHistory();
              _loadHistory();
            },
            child: Text(isEN ? 'Clear' : 'Temizle', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isDark, bool isEN) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3345), const Color(0xFF253D50)]
              : [const Color(0xFF2C6E8A), const Color(0xFF3D8FAF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('📊', '${_entries.length}', isEN ? 'Records' : 'Kayıt', isDark),
          _statItem('🔥', '$_streakDays', isEN ? 'Streak' : 'Seri', isDark),
          _statItem('⭐', _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '-',
              isEN ? 'Avg Rating' : 'Ort Puan', isDark),
          _statItem('🌡️', '${_averageTemp.round()}°', isEN ? 'Avg Temp' : 'Ort Sıcaklık', isDark),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String value, String label, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
        )),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }

  Widget _buildTopOutfitsCard(bool isDark, bool isEN) {
    final freq = _outfitFrequency;
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).toList();
    final maxCount = top.isNotEmpty ? top.first.value : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEN ? '🏆 Most Worn' : '🏆 En Çok Giyilen',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          ...top.asMap().entries.map((e) {
            final medal = ['🥇', '🥈', '🥉'][e.key];
            final ratio = e.value.value / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(medal, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.key, style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        )),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              [const Color(0xFFFFD700), Colors.grey, const Color(0xFFCD7F32)][e.key],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value.value}x', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.grey,
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeatherDistribution(bool isDark, bool isEN) {
    final freq = _conditionFrequency;
    final total = _entries.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEN ? '🌤️ Weather Distribution' : '🌤️ Hava Dağılımı',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: freq.entries.map((e) {
              final pct = (e.value / total * 100).round();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getConditionEmoji(e.key), style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text('$pct%', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(int index, bool isDark) {
    final entry = _entries[index];
    final dateStr =
        '${entry.date.day}.${entry.date.month.toString().padLeft(2, '0')}.${entry.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(_getConditionEmoji(entry.condition), style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.city,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.temperature.round()}° • ${entry.outfitTitle}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          _buildRatingStars(index, entry.rating, isDark),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int index, int? rating, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating != null && i < rating;
        return GestureDetector(
          onTap: () async {
            await HistoryService.updateRating(index, i + 1);
            _loadHistory();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: filled ? Colors.amber : (isDark ? Colors.white24 : Colors.grey[300]),
              size: 22,
            ),
          ),
        );
      }),
    );
  }

  String _getConditionEmoji(String condition) {
    switch (condition) {
      case 'clear': return '☀️';
      case 'clouds': return '⛅';
      case 'rain': return '🌧️';
      case 'drizzle': return '🌦️';
      case 'thunderstorm': return '⛈️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }
}
