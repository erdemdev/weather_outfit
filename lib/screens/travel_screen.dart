import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../services/weather_service.dart';
import '../l10n/app_localizations.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final _cityController = TextEditingController();
  final List<_TravelCity> _cities = [];
  bool _loadingCity = false;

  Future<void> _addCity(String city) async {
    if (city.trim().isEmpty) return;
    if (_cities.any((c) => c.name.toLowerCase() == city.toLowerCase())) return;

    setState(() => _loadingCity = true);
    try {
      final weather = await WeatherService.getWeatherByCity(city.trim());
      final outfit = OutfitEngine.getRecommendation(weather);
      setState(() {
        _cities.add(_TravelCity(
          name: weather.city,
          weather: weather,
          outfit: outfit,
        ));
      });
      _cityController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.lang == 'en' ? 'City not found' : 'Şehir bulunamadı'}: $city')),
        );
      }
    }
    setState(() => _loadingCity = false);
  }

  List<String> _generatePackingList() {
    final items = <String>{};
    for (final city in _cities) {
      for (final item in city.outfit.items) {
        items.add('${item.emoji} ${item.name}');
      }
      if (city.weather.isRainy) items.add('🌂 Şemsiye');
      if (city.weather.isCold) items.add('🧣 Atkı');
      if (city.weather.isHot) items.add('🧴 Güneş kremi');
    }
    return items.toList()..sort();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Travel Mode' : 'Seyahat Modu'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Şehir ekleme
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: isEN ? 'Add destination city...' : 'Hedef şehir ekle...',
                      prefixIcon: const Icon(Icons.flight_takeoff_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _addCity,
                  ),
                ),
                const SizedBox(width: 8),
                _loadingCity
                    ? const SizedBox(width: 48, height: 48, child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ))
                    : IconButton(
                        onPressed: () => _addCity(_cityController.text),
                        icon: const Icon(Icons.add_circle_rounded),
                        color: const Color(0xFF2C6E8A),
                        iconSize: 32,
                      ),
              ],
            ),
          ),

          // Şehir listesi
          Expanded(
            child: _cities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✈️', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          isEN ? 'Add cities to plan your trip outfit' : 'Seyahat kombini için şehir ekle',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._cities.map((city) => _CityCard(
                            city: city,
                            onRemove: () => setState(() => _cities.remove(city)),
                          )),
                      if (_cities.length >= 2) ...[
                        const SizedBox(height: 24),
                        _PackingListCard(items: _generatePackingList()),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TravelCity {
  final String name;
  final WeatherData weather;
  final OutfitRecommendation outfit;
  _TravelCity({required this.name, required this.weather, required this.outfit});
}

class _CityCard extends StatelessWidget {
  final _TravelCity city;
  final VoidCallback onRemove;
  const _CityCard({required this.city, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Row(
            children: [
              Text(_weatherEmoji(city.weather.condition), style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(city.name, style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    )),
                    Text(
                      '${city.weather.temperature.round()}°C • ${city.weather.description}',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(city.outfit.title, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF2C6E8A),
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: city.outfit.items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${item.emoji} ${item.name}', style: TextStyle(
                fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[800],
              )),
            )).toList(),
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

class _PackingListCard extends StatelessWidget {
  final List<String> items;
  const _PackingListCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2C6E8A).withOpacity(0.1), const Color(0xFF3A8FA8).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C6E8A).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧳', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                isEN ? 'Packing List' : 'Bavul Listesi',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 16,
                        color: isDark ? Colors.white38 : Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(item, style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[800],
                    )),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
