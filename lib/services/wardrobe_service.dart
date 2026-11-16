import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WardrobeItem {
  final String name;
  final String emoji;
  final String category;
  final int colorValue;
  final String? imagePath;

  WardrobeItem({
    required this.name,
    required this.emoji,
    required this.category,
    required this.colorValue,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'category': category,
        'colorValue': colorValue,
        if (imagePath != null) 'imagePath': imagePath,
      };

  factory WardrobeItem.fromJson(Map<String, dynamic> json) => WardrobeItem(
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        category: json['category'] as String,
        colorValue: json['colorValue'] as int,
        imagePath: json['imagePath'] as String?,
      );
}

class WardrobeService {
  static const _key = 'my_wardrobe';

  static Future<List<WardrobeItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((e) => WardrobeItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addItem(WardrobeItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      await prefs.setStringList(_key, data);
    }
  }

  static Future<void> updateItem(int index, WardrobeItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < data.length) {
      data[index] = jsonEncode(item.toJson());
      await prefs.setStringList(_key, data);
    }
  }

  static Future<List<WardrobeItem>> getByCategory(String category) async {
    final items = await getItems();
    return items.where((i) => i.category == category).toList();
  }
}
