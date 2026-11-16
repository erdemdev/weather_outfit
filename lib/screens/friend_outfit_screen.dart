import 'package:flutter/material.dart';
import '../services/friend_outfit_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../l10n/app_localizations.dart';

class FriendOutfitScreen extends StatefulWidget {
  const FriendOutfitScreen({super.key});

  @override
  State<FriendOutfitScreen> createState() => _FriendOutfitScreenState();
}

class _FriendOutfitScreenState extends State<FriendOutfitScreen> {
  WeatherData? _weather;
  String? _selectedType;
  OutfitRecommendation? _outfit1;
  OutfitRecommendation? _outfit2;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final w = await WeatherService.getWeatherByGPS();
      setState(() => _weather = w);
    } catch (_) {
      setState(() => _weather = WeatherData.demo());
    }
  }

  void _selectType(String pairType) {
    if (_weather == null) return;
    final (o1, o2) = FriendOutfitService.getMatchingOutfits(pairType, _weather!);
    setState(() {
      _selectedType = pairType;
      _outfit1 = o1;
      _outfit2 = o2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Friend Matching' : 'Arkadaş Kombini'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isEN ? 'Who are you matching with?' : 'Kiminle eşleşiyorsun?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 16),
                // Pair type selection
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: FriendOutfitService.styles.map((type) {
                      final selected = _selectedType == type['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => _selectType(type['id']!),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF2C6E8A) : isDark ? const Color(0xFF1B2A3D) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: selected ? const Color(0xFF2C6E8A) : Colors.transparent, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(type['emoji']!, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 6),
                                Text(isEN ? type['en']! : type['tr']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : isDark ? Colors.white70 : Colors.black87), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (_outfit1 != null && _outfit2 != null) ...[
                  const SizedBox(height: 24),
                  _buildOutfitCard(_outfit1!, isDark),
                  const SizedBox(height: 16),
                  _buildOutfitCard(_outfit2!, isDark),
                ],
              ],
            ),
    );
  }

  Widget _buildOutfitCard(OutfitRecommendation outfit, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(outfit.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(outfit.subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 16),
            ...outfit.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: item.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                  Container(width: 14, height: 14, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
                ],
              ),
            )),
            if (outfit.tip.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: outfit.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('💡 ${outfit.tip}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
