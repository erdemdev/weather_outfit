import 'package:flutter/material.dart';
import '../services/location_outfit_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../l10n/app_localizations.dart';

class LocationOutfitScreen extends StatefulWidget {
  const LocationOutfitScreen({super.key});

  @override
  State<LocationOutfitScreen> createState() => _LocationOutfitScreenState();
}

class _LocationOutfitScreenState extends State<LocationOutfitScreen> {
  WeatherData? _weather;
  OutfitRecommendation? _outfit;
  String? _selectedLocation;

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

  void _selectLocation(String id) {
    if (_weather == null) return;
    setState(() {
      _selectedLocation = id;
      _outfit = LocationOutfitService.getRecommendation(id, _weather!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Location Outfit' : 'Konum Kombini'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isEN ? 'Where are you going?' : 'Nereye gidiyorsun?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 16),
                // Location grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: LocationOutfitService.locations.map((loc) {
                    final selected = _selectedLocation == loc.id;
                    return InkWell(
                      onTap: () => _selectLocation(loc.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2C6E8A)
                              : isDark ? const Color(0xFF1B2A3D) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? const Color(0xFF2C6E8A) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(loc.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(
                              isEN ? loc.nameEN : loc.nameTR,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_outfit != null) ...[
                  const SizedBox(height: 24),
                  _buildOutfitCard(_outfit!, isDark, isEN),
                ],
              ],
            ),
    );
  }

  Widget _buildOutfitCard(OutfitRecommendation outfit, bool isDark, bool isEN) {
    return Card(
      color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(outfit.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(outfit.subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 16),
            ...outfit.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: item.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                  Container(width: 16, height: 16, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
                ],
              ),
            )),
            if (outfit.tip.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C6E8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(outfit.tip, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54))),
                  ],
                ),
              ),
            ],
            if (outfit.alerts.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...outfit.alerts.map((a) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(a, style: const TextStyle(color: Color(0xFFFFA726), fontWeight: FontWeight.w500)),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
