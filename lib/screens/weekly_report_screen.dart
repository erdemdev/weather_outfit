import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../l10n/app_localizations.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  List<HistoryEntry> _weekEntries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await HistoryService.getHistory();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    setState(() {
      _weekEntries = all.where((e) => e.date.isAfter(weekAgo)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    // Stats
    final outfitCounts = <String, int>{};
    final conditionCounts = <String, int>{};
    double totalTemp = 0;
    int ratedCount = 0;
    double ratingSum = 0;

    for (final e in _weekEntries) {
      outfitCounts[e.outfitTitle] = (outfitCounts[e.outfitTitle] ?? 0) + 1;
      conditionCounts[e.condition] = (conditionCounts[e.condition] ?? 0) + 1;
      totalTemp += e.temperature;
      if (e.rating != null) {
        ratedCount++;
        ratingSum += e.rating!;
      }
    }
    final avgTemp = _weekEntries.isNotEmpty ? totalTemp / _weekEntries.length : 0.0;
    final avgRating = ratedCount > 0 ? ratingSum / ratedCount : 0.0;
    final topOutfit = outfitCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topCondition = conditionCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Weekly Report' : 'Haftalık Rapor'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _weekEntries.isEmpty
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📊', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  isEN ? 'No data for this week' : 'Bu hafta veri yok',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                ),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overview cards
                Row(
                  children: [
                    Expanded(child: _statCard('📅', '${_weekEntries.length}', isEN ? 'Days' : 'Gün', const Color(0xFF2C6E8A), isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('🌡️', '${avgTemp.round()}°C', isEN ? 'Avg Temp' : 'Ort Sıcaklık', const Color(0xFFE8974A), isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('⭐', avgRating.toStringAsFixed(1), isEN ? 'Avg Rating' : 'Ort Puan', const Color(0xFF6B4FCF), isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                // Top outfits
                if (topOutfit.isNotEmpty) _buildSection(
                  isEN ? '👗 Most Worn' : '👗 En Çok Giyilen',
                  topOutfit.take(5).map((e) => _listItem(e.key, '${e.value}x', isDark)).toList(),
                  isDark,
                ),
                const SizedBox(height: 16),
                // Weather breakdown
                if (topCondition.isNotEmpty) _buildSection(
                  isEN ? '🌤️ Weather Summary' : '🌤️ Hava Özeti',
                  topCondition.map((e) => _listItem(
                    '${_condEmoji(e.key)} ${e.key}',
                    '${e.value} ${isEN ? 'days' : 'gün'}',
                    isDark,
                  )).toList(),
                  isDark,
                ),
                const SizedBox(height: 16),
                // Day by day
                _buildSection(
                  isEN ? '📋 Day by Day' : '📋 Gün Gün',
                  _weekEntries.map((e) => _listItem(
                    '${_condEmoji(e.condition)} ${e.outfitTitle}',
                    '${e.date.day}.${e.date.month} • ${e.temperature.round()}°C${e.rating != null ? ' ⭐${e.rating}' : ''}',
                    isDark,
                  )).toList(),
                  isDark,
                ),
              ],
            ),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
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
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _listItem(String title, String trailing, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(
            fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700],
          ))),
          Text(trailing, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C6E8A),
          )),
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
}
