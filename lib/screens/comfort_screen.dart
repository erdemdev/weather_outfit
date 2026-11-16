import 'package:flutter/material.dart';
import '../services/comfort_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class ComfortScreen extends StatefulWidget {
  const ComfortScreen({super.key});

  @override
  State<ComfortScreen> createState() => _ComfortScreenState();
}

class _ComfortScreenState extends State<ComfortScreen> {
  WeatherData? _weather;
  int _layerCount = 3;
  ComfortLevel? _comfort;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final w = await WeatherService.getWeatherByGPS();
      setState(() {
        _weather = w;
        _layerCount = ComfortService.getRecommendedLayers(w);
        _comfort = ComfortService.calculateComfort(w, _layerCount);
      });
    } catch (_) {
      final w = WeatherData.demo();
      setState(() {
        _weather = w;
        _layerCount = ComfortService.getRecommendedLayers(w);
        _comfort = ComfortService.calculateComfort(w, _layerCount);
      });
    }
  }

  void _updateLayers(int count) {
    if (_weather == null) return;
    setState(() {
      _layerCount = count;
      _comfort = ComfortService.calculateComfort(_weather!, count);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Temperature Comfort' : 'Sıcaklık Konforu'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Weather info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        const Text('🌡️', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text('${_weather!.temperature.round()}°C', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        Text(isEN ? 'Temp' : 'Sıcaklık', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
                      ]),
                      Column(children: [
                        const Text('💨', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text('${_weather!.windSpeed.round()} m/s', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        Text(isEN ? 'Wind' : 'Rüzgar', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
                      ]),
                      Column(children: [
                        const Text('💧', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text('%${_weather!.humidity}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        Text(isEN ? 'Humidity' : 'Nem', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Comfort meter
                if (_comfort != null) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_comfort!.color.withValues(alpha: 0.2), _comfort!.color.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _comfort!.color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(_comfort!.emoji, style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 8),
                        Text(
                          isEN ? _comfort!.titleEN : _comfort!.titleTR,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEN ? _comfort!.descEN : _comfort!.descTR,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Score bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _comfort!.score,
                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                            valueColor: AlwaysStoppedAnimation(_comfort!.color),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${(_comfort!.score * 100).round()}%', style: TextStyle(fontWeight: FontWeight.bold, color: _comfort!.color)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Layer selector
                Text(
                  isEN ? 'How many layers?' : 'Kaç kat giyiyorsun?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final count = i + 1;
                    final selected = count == _layerCount;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        onTap: () => _updateLayers(count),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF2C6E8A) : isDark ? const Color(0xFF1B2A3D) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? const Color(0xFF2C6E8A) : Colors.transparent),
                          ),
                          child: Center(child: Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: selected ? Colors.white : isDark ? Colors.white70 : Colors.black54))),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Center(child: Text(isEN ? 'recommended: ${ComfortService.getRecommendedLayers(_weather!)} layers' : 'önerilen: ${ComfortService.getRecommendedLayers(_weather!)} kat', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black26))),
                const SizedBox(height: 24),
                // Layer suggestions
                Text(
                  isEN ? 'Suggested Layers' : 'Önerilen Katmanlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 12),
                ...ComfortService.getLayerSuggestions(_weather!).asMap().entries.map((e) => Card(
                  color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2C6E8A).withValues(alpha: 0.15),
                      child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C6E8A))),
                    ),
                    title: Text(e.value, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ),
                )),
              ],
            ),
    );
  }
}
