import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingItem {
  final String name;
  final String category;
  final String emoji;
  final bool purchased;
  final double? estimatedPrice;

  ShoppingItem({
    required this.name,
    required this.category,
    required this.emoji,
    this.purchased = false,
    this.estimatedPrice,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'emoji': emoji,
    'purchased': purchased,
    'estimatedPrice': estimatedPrice,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    name: json['name'] as String,
    category: json['category'] as String,
    emoji: json['emoji'] as String,
    purchased: json['purchased'] as bool? ?? false,
    estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
  );

  ShoppingItem copyWith({bool? purchased}) => ShoppingItem(
    name: name,
    category: category,
    emoji: emoji,
    purchased: purchased ?? this.purchased,
    estimatedPrice: estimatedPrice,
  );
}

class ShoppingListService {
  static const _key = 'shopping_list';

  static Future<List<ShoppingItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => ShoppingItem.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  static Future<void> addItem(ShoppingItem item) async {
    final items = await getItems();
    items.add(item);
    await _save(items);
  }

  static Future<void> togglePurchased(int index) async {
    final items = await getItems();
    if (index >= 0 && index < items.length) {
      items[index] = items[index].copyWith(purchased: !items[index].purchased);
      await _save(items);
    }
  }

  static Future<void> removeItem(int index) async {
    final items = await getItems();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      await _save(items);
    }
  }

  static Future<void> clearPurchased() async {
    final items = await getItems();
    items.removeWhere((i) => i.purchased);
    await _save(items);
  }

  static Future<double> getEstimatedTotal() async {
    final items = await getItems();
    return items
        .where((i) => !i.purchased && i.estimatedPrice != null)
        .fold<double>(0.0, (sum, i) => sum + i.estimatedPrice!);
  }

  static Future<void> _save(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, items.map((e) => jsonEncode(e.toJson())).toList());
  }
}
