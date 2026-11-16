import '../services/wardrobe_service.dart';

class WardrobeGap {
  final String category;
  final String emoji;
  final String messageTR;
  final String messageEN;
  final int priority; // 1=kritik, 2=önemli, 3=iyi olur

  const WardrobeGap({
    required this.category,
    required this.emoji,
    required this.messageTR,
    required this.messageEN,
    required this.priority,
  });
}

class WardrobeAnalysisService {
  static const _idealMinimums = {
    'üst': 5,
    'alt': 3,
    'dış giyim': 2,
    'ayakkabı': 3,
    'aksesuar': 2,
  };

  /// Eksik kategori analizi
  static Future<List<WardrobeGap>> analyzeGaps() async {
    final items = await WardrobeService.getItems();
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }

    final gaps = <WardrobeGap>[];

    for (final entry in _idealMinimums.entries) {
      final count = counts[entry.key] ?? 0;
      if (count == 0) {
        gaps.add(WardrobeGap(
          category: entry.key,
          emoji: _categoryEmoji(entry.key),
          messageTR: '${_categoryNameTR(entry.key)} kategorisinde hiç kıyafet yok! En az ${entry.value} parça önerilir.',
          messageEN: 'No items in ${_categoryNameEN(entry.key)}! At least ${entry.value} pieces recommended.',
          priority: 1,
        ));
      } else if (count < entry.value) {
        gaps.add(WardrobeGap(
          category: entry.key,
          emoji: _categoryEmoji(entry.key),
          messageTR: '${_categoryNameTR(entry.key)}: $count parça var, ${entry.value} önerilir.',
          messageEN: '${_categoryNameEN(entry.key)}: $count items, ${entry.value} recommended.',
          priority: 2,
        ));
      }
    }

    // Renk çeşitliliği kontrolü
    final colorSet = items.map((i) => i.colorValue).toSet();
    if (items.length > 5 && colorSet.length < 3) {
      gaps.add(const WardrobeGap(
        category: 'renk',
        emoji: '🎨',
        messageTR: 'Renk çeşitliliğin az! Farklı renklerde parçalar ekle.',
        messageEN: 'Low color variety! Add pieces in different colors.',
        priority: 3,
      ));
    }

    // Mevsim kontrolü
    final hasWinterCoat = items.any((i) =>
        i.category == 'dış giyim' && (i.name.toLowerCase().contains('mont') || i.name.toLowerCase().contains('palto') || i.name.toLowerCase().contains('kaz')));
    if (!hasWinterCoat && items.isNotEmpty) {
      gaps.add(const WardrobeGap(
        category: 'dış giyim',
        emoji: '🧥',
        messageTR: 'Kışlık mont/palto eksik! Soğuk havalar için gerekli.',
        messageEN: 'Missing winter coat! Essential for cold weather.',
        priority: 2,
      ));
    }

    final hasRainGear = items.any((i) =>
        i.name.toLowerCase().contains('yağmurluk') || i.name.toLowerCase().contains('şemsiye'));
    if (!hasRainGear && items.isNotEmpty) {
      gaps.add(const WardrobeGap(
        category: 'aksesuar',
        emoji: '☔',
        messageTR: 'Yağmurluk veya şemsiye eksik!',
        messageEN: 'Missing raincoat or umbrella!',
        priority: 2,
      ));
    }

    gaps.sort((a, b) => a.priority.compareTo(b.priority));
    return gaps;
  }

  /// Kategori dağılım yüzdeleri
  static Future<Map<String, double>> getCategoryDistribution() async {
    final items = await WardrobeService.getItems();
    if (items.isEmpty) return {};
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts.map((k, v) => MapEntry(k, v / items.length * 100));
  }

  static String _categoryEmoji(String cat) => switch (cat) {
    'üst' => '👕',
    'alt' => '👖',
    'dış giyim' => '🧥',
    'ayakkabı' => '👟',
    'aksesuar' => '🧢',
    _ => '📦',
  };

  static String _categoryNameTR(String cat) => switch (cat) {
    'üst' => 'Üst giyim',
    'alt' => 'Alt giyim',
    'dış giyim' => 'Dış giyim',
    'ayakkabı' => 'Ayakkabı',
    'aksesuar' => 'Aksesuar',
    _ => cat,
  };

  static String _categoryNameEN(String cat) => switch (cat) {
    'üst' => 'Tops',
    'alt' => 'Bottoms',
    'dış giyim' => 'Outerwear',
    'ayakkabı' => 'Shoes',
    'aksesuar' => 'Accessories',
    _ => cat,
  };
}
