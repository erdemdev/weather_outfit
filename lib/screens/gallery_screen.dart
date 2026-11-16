import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<_GalleryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('outfit_gallery');
    if (raw != null) {
      setState(() {
        _entries = raw
            .map((e) => _GalleryEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  Future<void> _toggleLike(int index) async {
    setState(() {
      _entries[index] = _entries[index].copyWith(
        likes: _entries[index].likes + 1,
      );
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'outfit_gallery',
      _entries.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Outfit Gallery' : 'Kombin Galerisi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🖼️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    isEN ? 'No outfits shared yet' : 'Henüz paylaşılan kombin yok',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEN ? 'Share outfits from the home screen' : 'Ana ekrandan kombin paylaşın',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (ctx, i) => _GalleryCard(
                entry: _entries[i],
                onLike: () => _toggleLike(i),
              ),
            ),
    );
  }
}

class _GalleryEntry {
  final String outfitTitle;
  final String city;
  final double temperature;
  final String condition;
  final List<String> itemNames;
  final int primaryColor;
  final DateTime date;
  final int likes;

  _GalleryEntry({
    required this.outfitTitle,
    required this.city,
    required this.temperature,
    required this.condition,
    required this.itemNames,
    required this.primaryColor,
    required this.date,
    required this.likes,
  });

  _GalleryEntry copyWith({int? likes}) => _GalleryEntry(
        outfitTitle: outfitTitle,
        city: city,
        temperature: temperature,
        condition: condition,
        itemNames: itemNames,
        primaryColor: primaryColor,
        date: date,
        likes: likes ?? this.likes,
      );

  Map<String, dynamic> toJson() => {
        'outfitTitle': outfitTitle,
        'city': city,
        'temperature': temperature,
        'condition': condition,
        'itemNames': itemNames,
        'primaryColor': primaryColor,
        'date': date.toIso8601String(),
        'likes': likes,
      };

  factory _GalleryEntry.fromJson(Map<String, dynamic> json) => _GalleryEntry(
        outfitTitle: json['outfitTitle'] as String? ?? '',
        city: json['city'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
        condition: json['condition'] as String? ?? 'clear',
        itemNames: List<String>.from(json['itemNames'] as List? ?? []),
        primaryColor: json['primaryColor'] as int? ?? 0xFF2C6E8A,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        likes: json['likes'] as int? ?? 0,
      );
}

class _GalleryCard extends StatelessWidget {
  final _GalleryEntry entry;
  final VoidCallback onLike;
  const _GalleryCard({required this.entry, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(entry.primaryColor);
    final ago = DateTime.now().difference(entry.date);
    String agoText;
    if (ago.inMinutes < 60) {
      agoText = '${ago.inMinutes}dk';
    } else if (ago.inHours < 24) {
      agoText = '${ago.inHours}sa';
    } else {
      agoText = '${ago.inDays}g';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(_weatherEmoji(entry.condition), style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.city, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    )),
                    Text('${entry.temperature.round()}°C • $agoText',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Outfit title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.outfitTitle, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                )),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: entry.itemNames.map((name) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(name, style: TextStyle(
                      fontSize: 11, color: isDark ? Colors.white60 : Colors.grey[700],
                    )),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Like button
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(Icons.favorite_rounded, size: 18,
                        color: entry.likes > 0 ? Colors.redAccent : (isDark ? Colors.white24 : Colors.grey[300])),
                    const SizedBox(width: 4),
                    Text('${entry.likes}', style: TextStyle(
                      fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[500],
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _weatherEmoji(String condition) {
    switch (condition) {
      case 'clear': return '☀️';
      case 'clouds': return '☁️';
      case 'rain': case 'drizzle': return '🌧️';
      case 'thunderstorm': return '⛈️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }
}
