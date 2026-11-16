import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SocialPost {
  final String username;
  final String outfitTitle;
  final String emoji;
  final String city;
  final double temperature;
  final String condition;
  final int likes;
  final DateTime date;
  final List<String> tags;

  SocialPost({
    required this.username,
    required this.outfitTitle,
    required this.emoji,
    required this.city,
    required this.temperature,
    required this.condition,
    this.likes = 0,
    required this.date,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'outfitTitle': outfitTitle,
    'emoji': emoji,
    'city': city,
    'temperature': temperature,
    'condition': condition,
    'likes': likes,
    'date': date.toIso8601String(),
    'tags': tags,
  };

  factory SocialPost.fromJson(Map<String, dynamic> json) => SocialPost(
    username: json['username'] as String,
    outfitTitle: json['outfitTitle'] as String,
    emoji: json['emoji'] as String,
    city: json['city'] as String,
    temperature: (json['temperature'] as num).toDouble(),
    condition: json['condition'] as String,
    likes: json['likes'] as int? ?? 0,
    date: DateTime.parse(json['date'] as String),
    tags: (json['tags'] as List?)?.cast<String>() ?? [],
  );

  SocialPost copyWith({int? likes}) => SocialPost(
    username: username,
    outfitTitle: outfitTitle,
    emoji: emoji,
    city: city,
    temperature: temperature,
    condition: condition,
    likes: likes ?? this.likes,
    date: date,
    tags: tags,
  );
}

class SocialFeedService {
  static const _key = 'social_feed';

  static Future<List<SocialPost>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    final posts = data
        .map((e) => SocialPost.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    posts.sort((a, b) => b.date.compareTo(a.date));
    return posts;
  }

  static Future<void> addPost(SocialPost post) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(post.toJson()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> likePost(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index < data.length) {
      final post = SocialPost.fromJson(jsonDecode(data[index]) as Map<String, dynamic>);
      data[index] = jsonEncode(post.copyWith(likes: post.likes + 1).toJson());
      await prefs.setStringList(_key, data);
    }
  }

  static Future<void> removePost(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index < data.length) {
      data.removeAt(index);
      await prefs.setStringList(_key, data);
    }
  }

  // Demo posts
  static List<SocialPost> getDemoPosts() => [
    SocialPost(username: 'Elif ✨', outfitTitle: 'Bahar Enerjisi', emoji: '🌸', city: 'İstanbul', temperature: 18, condition: 'clear', likes: 24, date: DateTime.now().subtract(const Duration(hours: 2)), tags: ['bahar', 'casual']),
    SocialPost(username: 'Ahmet 🔥', outfitTitle: 'Şık İş Stili', emoji: '👔', city: 'Ankara', temperature: 14, condition: 'clouds', likes: 18, date: DateTime.now().subtract(const Duration(hours: 5)), tags: ['formal', 'iş']),
    SocialPost(username: 'Zeynep 💫', outfitTitle: 'Yağmurda Stil', emoji: '🌧️', city: 'İzmir', temperature: 16, condition: 'rain', likes: 31, date: DateTime.now().subtract(const Duration(hours: 8)), tags: ['yağmur', 'şık']),
    SocialPost(username: 'Can 🎯', outfitTitle: 'Spor Şık', emoji: '🏃', city: 'Antalya', temperature: 22, condition: 'clear', likes: 15, date: DateTime.now().subtract(const Duration(days: 1)), tags: ['spor', 'rahat']),
    SocialPost(username: 'Selin 🌈', outfitTitle: 'Renkli Gün', emoji: '🎨', city: 'Bursa', temperature: 20, condition: 'clear', likes: 42, date: DateTime.now().subtract(const Duration(days: 1)), tags: ['renkli', 'yaratıcı']),
  ];
}
