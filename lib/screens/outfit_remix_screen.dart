import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../l10n/app_localizations.dart';

class OutfitRemixScreen extends StatefulWidget {
  const OutfitRemixScreen({super.key});

  @override
  State<OutfitRemixScreen> createState() => _OutfitRemixScreenState();
}

class _OutfitRemixScreenState extends State<OutfitRemixScreen> {
  List<HistoryEntry> _history = [];
  HistoryEntry? _selected;
  List<String> _remixSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await HistoryService.getHistory();
    setState(() => _history = history);
  }

  void _generateRemix(HistoryEntry entry) {
    final isEN = AppStrings.lang == 'en';
    // Remix suggestions based on the original outfit
    final suggestions = <String>[];

    if (isEN) {
      suggestions.addAll([
        '🔄 Change the top: Try a different color or pattern',
        '👟 Swap shoes: Switch between casual and formal',
        '🧥 Add/remove a layer: Jacket, cardigan or vest',
        '🧢 Add a statement accessory: Hat, scarf, or watch',
        '🎨 Try the complementary color: Replace the main color',
        '👖 Switch bottoms: Jean → chinos, skirt → pants',
      ]);

      if (entry.condition == 'rain') {
        suggestions.add('☂️ Add a stylish raincoat instead of umbrella');
      }
      if (entry.temperature < 15) {
        suggestions.add('🧣 Layer with a knit sweater or turtleneck');
      }
      if (entry.temperature > 25) {
        suggestions.add('😎 Go sleeveless or switch to linen');
      }
    } else {
      suggestions.addAll([
        '🔄 Üstü değiştir: Farklı renk veya desen dene',
        '👟 Ayakkabı değiştir: Spor ↔ klasik geçiş yap',
        '🧥 Katman ekle/çıkar: Ceket, hırka veya yelek',
        '🧢 Dikkat çekici aksesuar ekle: Şapka, eşarp, saat',
        '🎨 Tamamlayıcı renk dene: Ana rengi değiştir',
        '👖 Alt değiştir: Jean → kumaş, etek → pantolon',
      ]);

      if (entry.condition == 'rain') {
        suggestions.add('☂️ Şemsiye yerine şık yağmurluk ekle');
      }
      if (entry.temperature < 15) {
        suggestions.add('🧣 Örgü kazak veya balıkçı yakayla katmanla');
      }
      if (entry.temperature > 25) {
        suggestions.add('😎 Kolsuz geç veya keten kumaşa dön');
      }
    }

    setState(() {
      _selected = entry;
      _remixSuggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Outfit Remix' : 'Kombin Remix'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _history.isEmpty
          ? Center(child: Text(
              isEN ? 'No outfit history yet' : 'Henüz kombin geçmişi yok',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isEN ? 'Pick an outfit to remix:' : 'Remix için bir kombin seç:',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _history.take(15).length,
                    itemBuilder: (ctx, i) {
                      final entry = _history[i];
                      final isSelected = _selected == entry;
                      final condEmoji = switch (entry.condition) {
                        'clear' => '☀️',
                        'clouds' => '⛅',
                        'rain' => '🌧️',
                        'snow' => '❄️',
                        _ => '🌤️',
                      };
                      return GestureDetector(
                        onTap: () => _generateRemix(entry),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2C6E8A)
                                : (isDark ? const Color(0xFF1E3345) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? null : Border.all(
                              color: isDark ? Colors.white12 : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$condEmoji ${entry.temperature.round()}°', style: TextStyle(
                                fontSize: 14, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                              )),
                              const SizedBox(height: 4),
                              Text(
                                entry.outfitTitle,
                                style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white70 : (isDark ? Colors.white38 : Colors.grey),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selected != null) ...[
                  const SizedBox(height: 20),
                  // Original
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3345) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEN ? '📋 Original Outfit' : '📋 Orijinal Kombin',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A2B35),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_selected!.outfitTitle} • ${_selected!.city} • ${_selected!.temperature.round()}°C',
                          style: TextStyle(
                            fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        if (_selected!.rating != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('⭐ ${_selected!.rating}/5', style: const TextStyle(fontSize: 13)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Remix suggestions
                  Text(
                    isEN ? '✨ Remix Suggestions' : '✨ Remix Önerileri',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._remixSuggestions.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3345) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C6E8A).withValues(alpha: 0.2)),
                    ),
                    child: Text(s, style: TextStyle(
                      fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700],
                      height: 1.4,
                    )),
                  )),
                ],
              ],
            ),
    );
  }
}
