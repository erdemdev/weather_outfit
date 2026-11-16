import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class WeatherCompareScreen extends StatefulWidget {
  const WeatherCompareScreen({super.key});

  @override
  State<WeatherCompareScreen> createState() => _WeatherCompareScreenState();
}

class _WeatherCompareScreenState extends State<WeatherCompareScreen> {
  final _city1Ctrl = TextEditingController();
  final _city2Ctrl = TextEditingController();
  WeatherData? _weather1;
  WeatherData? _weather2;
  bool _loading = false;

  Future<void> _compare() async {
    if (_city1Ctrl.text.isEmpty || _city2Ctrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final w1 = await WeatherService.getWeatherByCity(_city1Ctrl.text);
      final w2 = await WeatherService.getWeatherByCity(_city2Ctrl.text);
      setState(() {
        _weather1 = w1;
        _weather2 = w2;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.lang == 'en' ? 'City not found' : 'Şehir bulunamadı')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _city1Ctrl.dispose();
    _city2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Compare Weather' : 'Hava Karşılaştır'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // City inputs
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _city1Ctrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: isEN ? 'City 1' : 'Şehir 1',
                    prefixIcon: const Icon(Icons.location_city_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E3345) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('⚡', style: TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: TextField(
                  controller: _city2Ctrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _compare(),
                  decoration: InputDecoration(
                    hintText: isEN ? 'City 2' : 'Şehir 2',
                    prefixIcon: const Icon(Icons.location_city_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E3345) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _compare,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.compare_arrows_rounded),
              label: Text(isEN ? 'Compare' : 'Karşılaştır'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C6E8A),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (_weather1 != null && _weather2 != null) ...[
            const SizedBox(height: 20),
            _buildComparison(isDark, isEN),
          ],
        ],
      ),
    );
  }

  Widget _buildComparison(bool isDark, bool isEN) {
    final w1 = _weather1!;
    final w2 = _weather2!;

    return Column(
      children: [
        // City headers
        Row(
          children: [
            Expanded(child: _cityHeader(w1, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _cityHeader(w2, isDark)),
          ],
        ),
        const SizedBox(height: 12),
        _compareRow(isEN ? 'Temperature' : 'Sıcaklık', '${w1.temperature.round()}°C', '${w2.temperature.round()}°C', isDark),
        _compareRow(isEN ? 'Feels Like' : 'Hissedilen', '${w1.feelsLike.round()}°C', '${w2.feelsLike.round()}°C', isDark),
        _compareRow(isEN ? 'Humidity' : 'Nem', '${w1.humidity}%', '${w2.humidity}%', isDark),
        _compareRow(isEN ? 'Wind' : 'Rüzgar', '${w1.windSpeed.toStringAsFixed(1)} m/s', '${w2.windSpeed.toStringAsFixed(1)} m/s', isDark),
        _compareRow('UV', '${w1.uvIndex}', '${w2.uvIndex}', isDark),
      ],
    );
  }

  Widget _cityHeader(WeatherData w, bool isDark) {
    final emoji = switch (w.condition.toLowerCase()) {
      'clear' => '☀️',
      'clouds' => '⛅',
      'rain' => '🌧️',
      'drizzle' => '🌦️',
      'thunderstorm' => '⛈️',
      'snow' => '❄️',
      _ => '🌤️',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(w.city, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('${w.temperature.round()}°C', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(w.description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _compareRow(String label, String val1, String val2, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(val1, textAlign: TextAlign.center, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A2B35),
          ))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2C6E8A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF2C6E8A), fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(val2, textAlign: TextAlign.center, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A2B35),
          ))),
        ],
      ),
    );
  }
}
