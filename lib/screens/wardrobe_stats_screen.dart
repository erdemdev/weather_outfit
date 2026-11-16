import 'package:flutter/material.dart';
import '../services/wardrobe_service.dart';
import '../services/wardrobe_analysis_service.dart';
import '../l10n/app_localizations.dart';

class WardrobeStatsScreen extends StatefulWidget {
  const WardrobeStatsScreen({super.key});

  @override
  State<WardrobeStatsScreen> createState() => _WardrobeStatsScreenState();
}

class _WardrobeStatsScreenState extends State<WardrobeStatsScreen> {
  List<WardrobeItem> _items = [];
  List<WardrobeGap> _gaps = [];
  Map<String, double> _distribution = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await WardrobeService.getItems();
    final gaps = await WardrobeAnalysisService.analyzeGaps();
    final dist = await WardrobeAnalysisService.getCategoryDistribution();
    setState(() {
      _items = items;
      _gaps = gaps;
      _distribution = dist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Wardrobe Stats' : 'Dolap İstatistikleri'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _items.isEmpty
          ? Center(
              child: Text(
                isEN ? 'Add items to your wardrobe first' : 'Önce dolaba kıyafet ekle',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverview(isDark, isEN),
                const SizedBox(height: 16),
                _buildDistribution(isDark, isEN),
                const SizedBox(height: 16),
                _buildColorAnalysis(isDark, isEN),
                if (_gaps.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildGaps(isDark, isEN),
                ],
              ],
            ),
    );
  }

  Widget _buildOverview(bool isDark, bool isEN) {
    final categories = <String, int>{};
    for (final item in _items) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${_items.length}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          Text(
            isEN ? 'Total Items' : 'Toplam Parça',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: categories.entries.map((e) => Column(
              children: [
                Text(_emoji(e.key), style: const TextStyle(fontSize: 24)),
                Text('${e.value}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                Text(e.key, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDistribution(bool isDark, bool isEN) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEN ? '📊 Category Distribution' : '📊 Kategori Dağılımı',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          ..._distribution.entries.map((e) {
            final color = _categoryColor(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(_emoji(e.key), style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: TextStyle(
                          fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[700],
                        )),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / 100,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value.round()}%', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color,
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColorAnalysis(bool isDark, bool isEN) {
    final colorCounts = <int, int>{};
    for (final item in _items) {
      colorCounts[item.colorValue] = (colorCounts[item.colorValue] ?? 0) + 1;
    }
    final sorted = colorCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEN ? '🎨 Color Analysis' : '🎨 Renk Analizi',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: top.map((e) => Column(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Color(e.key),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${e.value}x', style: TextStyle(
                  fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600],
                )),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGaps(bool isDark, bool isEN) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEN ? '⚠️ Missing Items' : '⚠️ Eksik Parçalar',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          ..._gaps.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(g.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEN ? g.messageEN : g.messageTR,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
                _priorityBadge(g.priority),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _priorityBadge(int priority) {
    final (label, color) = switch (priority) {
      1 => ('!', Colors.red),
      2 => ('!!', Colors.orange),
      _ => ('?', Colors.blue),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  String _emoji(String cat) => switch (cat) {
    'üst' => '👕',
    'alt' => '👖',
    'dış giyim' => '🧥',
    'ayakkabı' => '👟',
    'aksesuar' => '🧢',
    _ => '📦',
  };

  Color _categoryColor(String cat) => switch (cat) {
    'üst' => const Color(0xFF5BA3D9),
    'alt' => const Color(0xFF3D5A80),
    'dış giyim' => const Color(0xFF7A6A5A),
    'ayakkabı' => const Color(0xFF4A8FA8),
    'aksesuar' => const Color(0xFFE8974A),
    _ => Colors.grey,
  };
}
