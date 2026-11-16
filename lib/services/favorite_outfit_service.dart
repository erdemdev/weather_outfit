import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteOutfit {
  final String title;
  final String subtitle;
  final String weatherMood;
  final List<FavoriteOutfitItem> items;
  final int primaryColorValue;
  final DateTime savedAt;

  FavoriteOutfit({
    required this.title,
    required this.subtitle,
    required this.weatherMood,
    required this.items,
    required this.primaryColorValue,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'weatherMood': weatherMood,
        'items': items.map((i) => i.toJson()).toList(),
        'primaryColorValue': primaryColorValue,
        'savedAt': savedAt.toIso8601String(),
      };

  factory FavoriteOutfit.fromJson(Map<String, dynamic> json) => FavoriteOutfit(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        weatherMood: json['weatherMood'] as String,
        items: (json['items'] as List)
            .map((e) => FavoriteOutfitItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        primaryColorValue: json['primaryColorValue'] as int,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class FavoriteOutfitItem {
  final String emoji;
  final String name;
  final String category;
  final int colorValue;

  FavoriteOutfitItem({
    required this.emoji,
    required this.name,
    required this.category,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'name': name,
        'category': category,
        'colorValue': colorValue,
      };

  factory FavoriteOutfitItem.fromJson(Map<String, dynamic> json) =>
      FavoriteOutfitItem(
        emoji: json['emoji'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        colorValue: json['colorValue'] as int,
      );
}

class FavoriteOutfitService {
  static const _key = 'favorite_outfits';

  static Future<List<FavoriteOutfit>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((e) => FavoriteOutfit.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  static Future<void> addFavorite(FavoriteOutfit outfit) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    // Aynı isimde varsa ekleme
    final exists = data.any((e) {
      final f = FavoriteOutfit.fromJson(jsonDecode(e) as Map<String, dynamic>);
      return f.title == outfit.title;
    });
    if (!exists) {
      data.add(jsonEncode(outfit.toJson()));
      if (data.length > 30) data.removeAt(0);
      await prefs.setStringList(_key, data);
    }
  }

  static Future<void> removeFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.removeWhere((e) {
      final f = FavoriteOutfit.fromJson(jsonDecode(e) as Map<String, dynamic>);
      return f.title == title;
    });
    await prefs.setStringList(_key, data);
  }

  static Future<bool> isFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.any((e) {
      final f = FavoriteOutfit.fromJson(jsonDecode(e) as Map<String, dynamic>);
      return f.title == title;
    });
  }
}
