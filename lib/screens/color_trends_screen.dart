import 'package:flutter/material.dart';
import '../services/wardrobe_service.dart';
import '../l10n/app_localizations.dart';

class ColorTrendsScreen extends StatefulWidget {
  const ColorTrendsScreen({super.key});

  @override
  State<ColorTrendsScreen> createState() => _ColorTrendsScreenState();
}

class _ColorTrendsScreenState extends State<ColorTrendsScreen> {
  List<WardrobeItem> _wardrobeItems = [];
  Map<int, int> _colorFrequency = {};

  // Trend colors by season
  static const _trendsByMonth = {
    1: [Color(0xFF1A1A2E), Color(0xFF8B0000), Color(0xFF2F4F4F), Color(0xFFF5F5DC)],
    2: [Color(0xFF8B0000), Color(0xFFFFC0CB), Color(0xFF1A1A2E), Color(0xFFDEB887)],
    3: [Color(0xFFF0E68C), Color(0xFF98FB98), Color(0xFFE6E6FA), Color(0xFFB0E0E6)],
    4: [Color(0xFF98FB98), Color(0xFFFFA07A), Color(0xFFE6E6FA), Color(0xFF87CEEB)],
    5: [Color(0xFFFFFFFF), Color(0xFF87CEEB), Color(0xFFFFA500), Color(0xFF90EE90)],
    6: [Color(0xFFFF6347), Color(0xFFFFD700), Color(0xFF00CED1), Color(0xFFFFFFFF)],
    7: [Color(0xFFFF4500), Color(0xFF1E90FF), Color(0xFFFFFF00), Color(0xFFFF69B4)],
    8: [Color(0xFFFF8C00), Color(0xFF20B2AA), Color(0xFFFFFFE0), Color(0xFF9370DB)],
    9: [Color(0xFF8B4513), Color(0xFFDAA520), Color(0xFF2F4F4F), Color(0xFFD2691E)],
    10: [Color(0xFF8B0000), Color(0xFFFF8C00), Color(0xFF556B2F), Color(0xFF4B0082)],
    11: [Color(0xFF2F4F4F), Color(0xFF8B4513), Color(0xFFA0522D), Color(0xFF696969)],
    12: [Color(0xFF8B0000), Color(0xFF006400), Color(0xFFFFD700), Color(0xFFC0C0C0)],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await WardrobeService.getItems();
    final colorFreq = <int, int>{};
    for (final item in items) {
      colorFreq[item.colorValue] = (colorFreq[item.colorValue] ?? 0) + 1;
    }
    setState(() {
      _wardrobeItems = items;
      _colorFrequency = colorFreq;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final month = DateTime.now().month;
    final trendColors = _trendsByMonth[month] ?? _trendsByMonth[1]!;
    final sortedColors = _colorFrequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Color Trends' : 'Renk Trendleri'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trend colors of the month
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  isEN ? '✨ Trend Colors This Month' : '✨ Bu Ayın Trend Renkleri',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: trendColors.map((c) => Column(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white30, width: 2),
                          boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _colorName(c, isEN),
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Your most used colors
          Text(
            isEN ? '🎨 Your Most Used Colors' : '🎨 En Çok Kullandığın Renkler',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          if (sortedColors.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(
                isEN ? 'Add items to see color analysis' : 'Renk analizi için parça ekle',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              )),
            )
          else
            ...sortedColors.take(10).map((e) {
              final maxCount = sortedColors.first.value;
              final pct = maxCount > 0 ? e.value / maxCount : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Color(e.key),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 10,
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                          color: Color(e.key),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.value}x', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    )),
                  ],
                ),
              );
            }),

          const SizedBox(height: 20),
          // Category colors
          Text(
            isEN ? '📊 Color by Category' : '📊 Kategoriye Göre Renk',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          ..._buildCategoryColors(isDark, isEN),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryColors(bool isDark, bool isEN) {
    final categories = ['üst', 'alt', 'dış giyim', 'ayakkabı', 'aksesuar'];
    final catEmoji = {'üst': '👕', 'alt': '👖', 'dış giyim': '🧥', 'ayakkabı': '👟', 'aksesuar': '🧢'};

    return categories.map((cat) {
      final catItems = _wardrobeItems.where((i) => i.category == cat).toList();
      if (catItems.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3345) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(catEmoji[cat] ?? '📦', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(cat, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[700],
            )),
            const Spacer(),
            ...catItems.take(8).map((item) => Container(
              width: 20, height: 20, margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 0.5),
              ),
            )),
          ],
        ),
      );
    }).toList();
  }

  String _colorName(Color c, bool isEN) {
    final hsl = HSLColor.fromColor(c);
    if (hsl.saturation < 0.1) {
      if (hsl.lightness > 0.9) return isEN ? 'White' : 'Beyaz';
      if (hsl.lightness < 0.15) return isEN ? 'Black' : 'Siyah';
      return isEN ? 'Gray' : 'Gri';
    }
    final hue = hsl.hue;
    if (hue < 15 || hue >= 345) return isEN ? 'Red' : 'Kırmızı';
    if (hue < 45) return isEN ? 'Orange' : 'Turuncu';
    if (hue < 70) return isEN ? 'Yellow' : 'Sarı';
    if (hue < 160) return isEN ? 'Green' : 'Yeşil';
    if (hue < 200) return isEN ? 'Teal' : 'Turkuaz';
    if (hue < 260) return isEN ? 'Blue' : 'Mavi';
    if (hue < 290) return isEN ? 'Purple' : 'Mor';
    return isEN ? 'Pink' : 'Pembe';
  }
}
