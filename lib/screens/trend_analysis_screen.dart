import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../l10n/app_localizations.dart';

class TrendAnalysisScreen extends StatefulWidget {
  const TrendAnalysisScreen({super.key});

  @override
  State<TrendAnalysisScreen> createState() => _TrendAnalysisScreenState();
}

class _TrendAnalysisScreenState extends State<TrendAnalysisScreen> {
  List<HistoryEntry> _all = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await HistoryService.getHistory();
    setState(() => _all = all);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    // Condition frequency
    final condCounts = <String, int>{};
    final monthlyCounts = <String, int>{};
    final ratingDist = <int, int>{};
    final monthlyTemp = <String, List<double>>{};

    for (final e in _all) {
      condCounts[e.condition] = (condCounts[e.condition] ?? 0) + 1;
      final mKey = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      monthlyCounts[mKey] = (monthlyCounts[mKey] ?? 0) + 1;
      if (e.rating != null) {
        ratingDist[e.rating!] = (ratingDist[e.rating!] ?? 0) + 1;
      }
      monthlyTemp.putIfAbsent(mKey, () => []).add(e.temperature);
    }

    final sortedCond = condCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedMonths = monthlyCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Trend Analysis' : 'Trend Analizi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _all.isEmpty
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📈', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  isEN ? 'Not enough data yet' : 'Henüz yeterli veri yok',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                ),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat('📊', '${_all.length}', isEN ? 'Total Records' : 'Toplam Kayıt'),
                      _miniStat('📅', '${sortedMonths.length}', isEN ? 'Months' : 'Ay'),
                      _miniStat('🌡️', '${_avgTemp().round()}°C', isEN ? 'Avg Temp' : 'Ort Sıcaklık'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Weather conditions
                _sectionCard(
                  isEN ? '🌤️ Weather Conditions' : '🌤️ Hava Durumları',
                  Column(
                    children: sortedCond.map((e) {
                      final pct = _all.isNotEmpty ? e.value / _all.length : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(_condEmoji(e.key), style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 10,
                                  backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                                  color: _condColor(e.key),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(pct * 100).round()}%', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  isDark,
                ),
                const SizedBox(height: 16),

                // Monthly activity
                _sectionCard(
                  isEN ? '📅 Monthly Activity' : '📅 Aylık Aktivite',
                  Column(
                    children: sortedMonths.take(12).map((e) {
                      final maxCount = sortedMonths.map((m) => m.value).reduce((a, b) => a > b ? a : b);
                      final pct = maxCount > 0 ? e.value / maxCount : 0.0;
                      final avgTemp = monthlyTemp[e.key] != null
                          ? monthlyTemp[e.key]!.reduce((a, b) => a + b) / monthlyTemp[e.key]!.length
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 55, child: Text(e.key, style: TextStyle(
                              fontSize: 11, color: isDark ? Colors.white54 : Colors.grey,
                            ))),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                                  color: const Color(0xFF2C6E8A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${e.value}', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            )),
                            const SizedBox(width: 6),
                            Text('${avgTemp.round()}°', style: TextStyle(
                              fontSize: 10, color: isDark ? Colors.white38 : Colors.grey,
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  isDark,
                ),
                const SizedBox(height: 16),

                // Rating distribution
                if (ratingDist.isNotEmpty) _sectionCard(
                  isEN ? '⭐ Rating Distribution' : '⭐ Puan Dağılımı',
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      final count = ratingDist[star] ?? 0;
                      final maxR = ratingDist.values.isEmpty ? 1 : ratingDist.values.reduce((a, b) => a > b ? a : b);
                      final height = maxR > 0 ? (count / maxR * 60).toDouble() : 0.0;
                      return Column(
                        children: [
                          Text('$count', style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          )),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: height + 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('$star⭐', style: const TextStyle(fontSize: 11)),
                        ],
                      );
                    }),
                  ),
                  isDark,
                ),
              ],
            ),
    );
  }

  double _avgTemp() {
    if (_all.isEmpty) return 0;
    return _all.map((e) => e.temperature).reduce((a, b) => a + b) / _all.length;
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _sectionCard(String title, Widget child, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A2B35),
          )),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _condEmoji(String c) => switch (c) {
    'clear' => '☀️',
    'clouds' => '⛅',
    'rain' => '🌧️',
    'drizzle' => '🌦️',
    'thunderstorm' => '⛈️',
    'snow' => '❄️',
    _ => '🌤️',
  };

  Color _condColor(String c) => switch (c) {
    'clear' => const Color(0xFFF4A72C),
    'clouds' => const Color(0xFF7A8FA8),
    'rain' => const Color(0xFF4A8FA8),
    'drizzle' => const Color(0xFF5BA3D9),
    'thunderstorm' => const Color(0xFF5A4A8A),
    'snow' => const Color(0xFFB0C4DE),
    _ => Colors.grey,
  };
}
