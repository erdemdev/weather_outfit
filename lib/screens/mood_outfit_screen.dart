import 'package:flutter/material.dart';
import '../services/mood_outfit_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../l10n/app_localizations.dart';

class MoodOutfitScreen extends StatefulWidget {
  const MoodOutfitScreen({super.key});

  @override
  State<MoodOutfitScreen> createState() => _MoodOutfitScreenState();
}

class _MoodOutfitScreenState extends State<MoodOutfitScreen> {
  WeatherData? _weather;
  OutfitRecommendation? _outfit;
  String? _selectedMood;

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

  void _selectMood(String moodId) {
    if (_weather == null) return;
    setState(() {
      _selectedMood = moodId;
      _outfit = MoodOutfitService.getRecommendation(moodId, _weather!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Mood Outfit' : 'Ruh Hali Kombini'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isEN ? 'How are you feeling today?' : 'Bugün nasıl hissediyorsun?',
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.5,
                  children: MoodOutfitService.moods.map((m) {
                    final id = m['id'] as String;
                    final selected = _selectedMood == id;
                    return GestureDetector(
                      onTap: () => _selectMood(id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2C6E8A)
                              : (isDark ? const Color(0xFF1E3345) : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: selected ? null : Border.all(
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(m['emoji'] as String, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isEN ? m['en'] as String : m['tr'] as String,
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_outfit != null) ...[
                  const SizedBox(height: 20),
                  _buildOutfitCard(isDark),
                ],
              ],
            ),
    );
  }

  Widget _buildOutfitCard(bool isDark) {
    final o = _outfit!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [o.primaryColor, o.secondaryColor]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: o.primaryColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(o.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(o.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          ...o.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14))),
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(o.tip, style: const TextStyle(color: Colors.white70, fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
