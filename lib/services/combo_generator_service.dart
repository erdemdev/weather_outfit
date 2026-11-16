import 'package:flutter/material.dart';
import 'wardrobe_service.dart';
import 'color_harmony_service.dart';

class GeneratedCombo {
  final List<WardrobeItem> items;
  final double harmonyScore;
  final String titleTR;
  final String titleEN;

  GeneratedCombo({
    required this.items,
    required this.harmonyScore,
    required this.titleTR,
    required this.titleEN,
  });
}

class ComboGeneratorService {
  /// Dolaptaki parçalardan uyumlu kombiler oluştur
  static Future<List<GeneratedCombo>> generate({
    String? targetCondition,
    double? temperature,
    int maxResults = 5,
  }) async {
    final items = await WardrobeService.getItems();
    if (items.length < 2) return [];

    final tops = items.where((i) => i.category == 'üst').toList();
    final bottoms = items.where((i) => i.category == 'alt').toList();
    final outerwear = items.where((i) => i.category == 'dış giyim').toList();
    final shoes = items.where((i) => i.category == 'ayakkabı').toList();
    final accessories = items.where((i) => i.category == 'aksesuar').toList();

    if (tops.isEmpty || bottoms.isEmpty) return [];

    final combos = <GeneratedCombo>[];
    final needOuterwear = temperature != null && temperature < 15;

    for (final top in tops) {
      for (final bottom in bottoms) {
        final comboItems = <WardrobeItem>[top, bottom];
        final colors = <Color>[Color(top.colorValue), Color(bottom.colorValue)];

        if (needOuterwear && outerwear.isNotEmpty) {
          final outer = _bestMatch(outerwear, colors);
          comboItems.add(outer);
          colors.add(Color(outer.colorValue));
        }

        if (shoes.isNotEmpty) {
          final shoe = _bestMatch(shoes, colors);
          comboItems.add(shoe);
          colors.add(Color(shoe.colorValue));
        }

        if (accessories.isNotEmpty) {
          final acc = _bestMatch(accessories, colors);
          comboItems.add(acc);
          colors.add(Color(acc.colorValue));
        }

        final score = ColorHarmony.outfitScore(colors);
        combos.add(GeneratedCombo(
          items: comboItems,
          harmonyScore: score,
          titleTR: '${top.name} + ${bottom.name}',
          titleEN: '${top.name} + ${bottom.name}',
        ));
      }
    }

    combos.sort((a, b) => b.harmonyScore.compareTo(a.harmonyScore));
    return combos.take(maxResults).toList();
  }

  static WardrobeItem _bestMatch(List<WardrobeItem> options, List<Color> existingColors) {
    WardrobeItem best = options.first;
    double bestScore = -1;
    for (final item in options) {
      final allColors = [...existingColors, Color(item.colorValue)];
      final score = ColorHarmony.outfitScore(allColors);
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    return best;
  }
}
