import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClothingPhoto {
  final String itemName;
  final String category;
  final String photoPath;
  final DateTime addedDate;
  final int? aiScore;
  final String? aiGrade;
  final List<String>? aiTips;

  ClothingPhoto({
    required this.itemName,
    this.category = '',
    required this.photoPath,
    required this.addedDate,
    this.aiScore,
    this.aiGrade,
    this.aiTips,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'category': category,
    'photoPath': photoPath,
    'addedDate': addedDate.toIso8601String(),
    if (aiScore != null) 'aiScore': aiScore,
    if (aiGrade != null) 'aiGrade': aiGrade,
    if (aiTips != null) 'aiTips': aiTips,
  };

  factory ClothingPhoto.fromJson(Map<String, dynamic> json) => ClothingPhoto(
    itemName: json['itemName'] as String,
    category: json['category'] as String? ?? '',
    photoPath: json['photoPath'] as String,
    addedDate: DateTime.parse(json['addedDate'] as String),
    aiScore: json['aiScore'] as int?,
    aiGrade: json['aiGrade'] as String?,
    aiTips: (json['aiTips'] as List<dynamic>?)?.cast<String>(),
  );
}

class PhotoService {
  static const _key = 'clothing_photos';

  static Future<List<ClothingPhoto>> getPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((e) => ClothingPhoto.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addPhoto(ClothingPhoto photo) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(photo.toJson()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> removePhoto(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index < data.length) {
      data.removeAt(index);
      await prefs.setStringList(_key, data);
    }
  }

  static Future<String?> getPhotoForItem(String itemName) async {
    final photos = await getPhotos();
    final match = photos.where((p) => p.itemName == itemName);
    return match.isNotEmpty ? match.last.photoPath : null;
  }

  static Future<Map<String, String>> getAllPhotoPaths() async {
    final photos = await getPhotos();
    final map = <String, String>{};
    for (final p in photos) {
      map[p.itemName] = p.photoPath;
    }
    return map;
  }
}
