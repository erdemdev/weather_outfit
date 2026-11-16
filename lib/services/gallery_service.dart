import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryService {
  static Future<void> addEntry({
    required String outfitTitle,
    required String city,
    required double temperature,
    required String condition,
    required List<String> itemNames,
    required int primaryColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('outfit_gallery') ?? [];
    data.add(jsonEncode({
      'outfitTitle': outfitTitle,
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'itemNames': itemNames,
      'primaryColor': primaryColor,
      'date': DateTime.now().toIso8601String(),
      'likes': 0,
    }));
    if (data.length > 100) data.removeAt(0);
    await prefs.setStringList('outfit_gallery', data);
  }
}
