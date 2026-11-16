import 'package:flutter/material.dart';
import '../services/multi_city_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../l10n/app_localizations.dart';

class _CityWeather {
  final String city;
  final WeatherData weather;
  final OutfitRecommendation outfit;
  _CityWeather({required this.city, required this.weather, required this.outfit});
}

class MultiCityScreen extends StatefulWidget {
  const MultiCityScreen({super.key});

  @override
  State<MultiCityScreen> createState() => _MultiCityScreenState();
}

class _MultiCityScreenState extends State<MultiCityScreen> {
  final _controller = TextEditingController();
  final List<_CityWeather> _cities = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    final saved = await MultiCityService.getCities();
    for (final city in saved) {
      await _fetchCity(city, save: false);
    }
  }

  Future<void> _fetchCity(String city, {bool save = true}) async {
    if (_cities.any((c) => c.city.toLowerCase() == city.toLowerCase())) return;
    setState(() => _loading = true);
    try {
      final weather = await WeatherService.getWeatherByCity(city);
      final outfit = OutfitEngine.getRecommendation(weather);
      if (save) await MultiCityService.addCity(city);
      setState(() {
        _cities.add(_CityWeather(city: weather.city, weather: weather, outfit: outfit));
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$city bulunamadı')),
        );
      }
    }
  }

  Future<void> _removeCity(int index) async {
    await MultiCityService.removeCity(_cities[index].city);
    setState(() => _cities.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Multi-City Tracking' : 'Çoklu Şehir Takibi'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: isEN ? 'Add city...' : 'Şehir ekle...',
                      prefixIcon: const Icon(Icons.add_location_rounded, color: Color(0xFF2C6E8A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E3345) : Colors.white,
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    onSubmitted: (city) {
                      if (city.trim().isNotEmpty) {
                        _fetchCity(city.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _fetchCity(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  backgroundColor: const Color(0xFF2C6E8A),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(color: Color(0xFF2C6E8A)),
          Expanded(
            child: _cities.isEmpty
                ? Center(child: Text(isEN ? 'Add cities to track' : 'Takip etmek için şehir ekle', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cities.length,
                    itemBuilder: (_, i) => _buildCityCard(_cities[i], i, isDark, isEN),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(_CityWeather cw, int index, bool isDark, bool isEN) {
    final w = cw.weather;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(_emoji(w.condition), style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.city, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                const SizedBox(height: 4),
                Text('${w.temperature.round()}°C — ${w.description}', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700])),
                const SizedBox(height: 2),
                Text('💨 ${w.windSpeed.round()} km/s   💧 %${w.humidity}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              Text('${w.tempMax.round()}°', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF2C6E8A))),
              Text('${w.tempMin.round()}°', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white38 : Colors.grey),
            onPressed: () => _removeCity(index),
          ),
        ],
      ),
    );
  }

  String _emoji(String condition) {
    switch (condition) {
      case 'clear': return '☀️';
      case 'clouds': return '⛅';
      case 'rain': return '🌧️';
      case 'drizzle': return '🌦️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }
}
