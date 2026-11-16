import '../services/wardrobe_service.dart';
import 'package:flutter/material.dart';

class CapsuleOutfit {
  final String title;
  final String emoji;
  final List<String> itemNames;

  const CapsuleOutfit({
    required this.title,
    required this.emoji,
    required this.itemNames,
  });
}

class CapsuleWardrobeService {
  /// Find a minimal wardrobe subset that maximizes combinations
  static Future<Map<String, dynamic>> generateCapsule({int targetSize = 15}) async {
    final wardrobe = await WardrobeService.getItems();

    if (wardrobe.isEmpty) {
      return {
        'items': <WardrobeItem>[],
        'combos': <CapsuleOutfit>[],
        'score': 0,
      };
    }

    // Group by category
    final categories = <String, List<WardrobeItem>>{};
    for (final item in wardrobe) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    // Select essential items from each category
    final capsule = <WardrobeItem>[];
    final essentialCounts = {
      'Üst Giyim': 5,
      'Alt Giyim': 3,
      'Dış Giyim': 2,
      'Ayakkabı': 3,
      'Aksesuar': 2,
    };

    for (final entry in essentialCounts.entries) {
      final items = categories[entry.key] ?? [];
      // Select most versatile (neutral colors first)
      items.sort((a, b) {
        final aNeut = _isNeutral(Color(a.colorValue)) ? 0 : 1;
        final bNeut = _isNeutral(Color(b.colorValue)) ? 0 : 1;
        return aNeut.compareTo(bNeut);
      });
      capsule.addAll(items.take(entry.value));
    }

    // Generate combinations
    final tops = capsule.where((i) => i.category == 'Üst Giyim').toList();
    final bottoms = capsule.where((i) => i.category == 'Alt Giyim').toList();
    final outers = capsule.where((i) => i.category == 'Dış Giyim').toList();
    final shoes = capsule.where((i) => i.category == 'Ayakkabı').toList();

    final combos = <CapsuleOutfit>[];
    int count = 0;
    for (final top in tops) {
      for (final bottom in bottoms) {
        for (final shoe in shoes) {
          count++;
          if (combos.length < 10) {
            combos.add(CapsuleOutfit(
              title: 'Kombin #$count',
              emoji: '👗',
              itemNames: [
                '${top.emoji} ${top.name}',
                '${bottom.emoji} ${bottom.name}',
                '${shoe.emoji} ${shoe.name}',
              ],
            ));
          }
        }
      }
    }

    // With outerwear
    final outerCombos = count * (outers.isEmpty ? 1 : outers.length);

    return {
      'items': capsule,
      'combos': combos,
      'totalCombos': outerCombos,
      'score': _calculateScore(capsule, outerCombos),
    };
  }

  static bool _isNeutral(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.saturation < 0.15 || hsl.lightness < 0.2 || hsl.lightness > 0.85;
  }

  static int _calculateScore(List<WardrobeItem> capsule, int combos) {
    if (capsule.isEmpty) return 0;
    // Score based on combo/item ratio
    final ratio = combos / capsule.length;
    if (ratio >= 5) return 5;
    if (ratio >= 3) return 4;
    if (ratio >= 2) return 3;
    if (ratio >= 1) return 2;
    return 1;
  }

  /// Get tips for improving capsule wardrobe
  static Future<List<String>> getTips() async {
    final wardrobe = await WardrobeService.getItems();
    final tips = <String>[];

    if (wardrobe.isEmpty) {
      tips.add('👗 Dolabına parça ekleyerek başla!');
      return tips;
    }

    final categories = <String, int>{};
    for (final item in wardrobe) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;
    }

    if (!categories.containsKey('Alt Giyim') || categories['Alt Giyim']! < 3) {
      tips.add('👖 Daha fazla alt giyim ekle — kombinasyonları artırır!');
    }
    if (!categories.containsKey('Dış Giyim') || categories['Dış Giyim']! < 2) {
      tips.add('🧥 Bir-iki dış giyim ekle — her kombine farklılık katar.');
    }

    final neutralCount = wardrobe.where((i) => _isNeutral(Color(i.colorValue))).length;
    if (neutralCount < wardrobe.length * 0.3) {
      tips.add('🎨 Daha fazla nötr renk ekle — uyum kolaylaşır!');
    }

    if (tips.isEmpty) {
      tips.add('✅ Dolabın çok dengeli! Harika bir kapsül gardırobun var.');
    }

    return tips;
  }
}
