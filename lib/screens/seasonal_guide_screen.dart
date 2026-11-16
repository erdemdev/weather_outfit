import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class _SeasonTip {
  final String emoji;
  final String titleTR;
  final String titleEN;
  final List<String> addTR;
  final List<String> addEN;
  final List<String> removeTR;
  final List<String> removeEN;

  const _SeasonTip({
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.addTR,
    required this.addEN,
    required this.removeTR,
    required this.removeEN,
  });
}

const _seasonTips = [
  _SeasonTip(
    emoji: '🌸', titleTR: 'İlkbahar Geçişi', titleEN: 'Spring Transition',
    addTR: ['İnce hırka / ceket', 'Trençkot', 'Pastel tonlar üst giyim', 'Sneaker / bez ayakkabı', 'Hafif eşarp'],
    addEN: ['Light cardigan / jacket', 'Trench coat', 'Pastel tops', 'Sneakers / canvas shoes', 'Light scarf'],
    removeTR: ['Kaz tüyü mont', 'Termal içlik', 'Kar botu', 'Kalın atkı & bere'],
    removeEN: ['Down jacket', 'Thermal underwear', 'Snow boots', 'Heavy scarf & beanie'],
  ),
  _SeasonTip(
    emoji: '☀️', titleTR: 'Yaz Dolabı', titleEN: 'Summer Wardrobe',
    addTR: ['Kısa kollu tişörtler', 'Şort & etek', 'Sandalet', 'Güneş gözlüğü & şapka', 'Hafif elbiseler'],
    addEN: ['Short sleeve tees', 'Shorts & skirts', 'Sandals', 'Sunglasses & hat', 'Light dresses'],
    removeTR: ['Trençkot', 'Uzun kollu kazaklar', 'Bot', 'Kalın kot pantolon'],
    removeEN: ['Trench coat', 'Long sleeve sweaters', 'Boots', 'Heavy jeans'],
  ),
  _SeasonTip(
    emoji: '🍂', titleTR: 'Sonbahar Hazırlığı', titleEN: 'Autumn Prep',
    addTR: ['Katmanlı üst giyim', 'Kot ceket / deri ceket', 'Chelsea bot', 'Toprak tonları kıyafetler', 'Hafif atkı'],
    addEN: ['Layered tops', 'Denim / leather jacket', 'Chelsea boots', 'Earth tone clothes', 'Light scarf'],
    removeTR: ['Sandalet', 'Şort', 'Çok ince tişörtler', 'Hasır şapka'],
    removeEN: ['Sandals', 'Shorts', 'Very thin tees', 'Straw hat'],
  ),
  _SeasonTip(
    emoji: '❄️', titleTR: 'Kış Dolabı', titleEN: 'Winter Wardrobe',
    addTR: ['Kalın mont / palto', 'Termal içlik', 'Yün kazak', 'Kar botu / kışlık bot', 'Atkı, bere, eldiven'],
    addEN: ['Heavy coat', 'Thermal underwear', 'Wool sweater', 'Snow / winter boots', 'Scarf, beanie, gloves'],
    removeTR: ['İnce hırka', 'Bez ayakkabı', 'Açık elbiseler', 'Hafif eşarp'],
    removeEN: ['Light cardigan', 'Canvas shoes', 'Light dresses', 'Light scarf'],
  ),
];

class SeasonalGuideScreen extends StatelessWidget {
  const SeasonalGuideScreen({super.key});

  int _currentSeasonIndex() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 0; // İlkbahar
    if (month >= 6 && month <= 8) return 1; // Yaz
    if (month >= 9 && month <= 11) return 2; // Sonbahar
    return 3; // Kış
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final currentSeason = _currentSeasonIndex();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Seasonal Guide' : 'Mevsim Rehberi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seasonTips.length,
        itemBuilder: (ctx, i) {
          final tip = _seasonTips[i];
          final isCurrent = i == currentSeason;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3345) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isCurrent ? Border.all(color: const Color(0xFF2C6E8A), width: 2) : null,
              boxShadow: isCurrent ? [
                BoxShadow(color: const Color(0xFF2C6E8A).withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
              ] : null,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF2C6E8A).withValues(alpha: 0.1) : null,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Text(tip.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEN ? tip.titleEN : tip.titleTR,
                              style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A2B35),
                              ),
                            ),
                            if (isCurrent) Text(
                              isEN ? '📍 Current Season' : '📍 Şu anki mevsim',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF2C6E8A), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildList(
                          isEN ? '✅ Add' : '✅ Ekle',
                          isEN ? tip.addEN : tip.addTR,
                          Colors.green,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildList(
                          isEN ? '📦 Remove' : '📦 Kaldır',
                          isEN ? tip.removeEN : tip.removeTR,
                          Colors.orange,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(String title, List<String> items, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: color, fontSize: 12)),
              Expanded(
                child: Text(item, style: TextStyle(
                  fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[700],
                )),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
