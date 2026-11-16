import 'package:flutter/material.dart';
import '../services/packing_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  final _cityController = TextEditingController();
  final _daysController = TextEditingController(text: '3');
  List<PackingItem> _items = [];
  final Set<int> _checked = {};
  List<WeatherData> _weatherList = [];
  bool _loading = false;

  @override
  void dispose() {
    _cityController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final city = _cityController.text.trim();
    final days = int.tryParse(_daysController.text) ?? 3;
    if (city.isEmpty) return;

    setState(() => _loading = true);
    try {
      final weather = await WeatherService.getWeatherByCity(city);
      final weatherList = [weather];
      final items = PackingService.generatePackingList(weatherList, days);
      setState(() {
        _weatherList = weatherList;
        _items = items;
        _checked.clear();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final categories = _items.map((e) => e.category).toSet().toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Packing List' : 'Bavul Hazırlayıcı'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3345) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: isEN ? 'Destination city' : 'Hedef şehir',
                    prefixIcon: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF2C6E8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: isEN ? 'Days' : 'Gün',
                          prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF2C6E8A)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
                        ),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _loading ? null : _generate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C6E8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEN ? 'Generate' : 'Oluştur'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_weatherList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_emoji(_weatherList[0].condition), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('${_weatherList[0].city} — ${_weatherList[0].temperature.round()}°C',
                    style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF2C6E8A))),
                  const Spacer(),
                  Text('${_checked.length}/${_items.length}', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _items.isEmpty
                ? Center(child: Text(isEN ? 'Enter a city to generate packing list' : 'Bavul listesi için şehir gir',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: categories.map((cat) => _buildCategory(cat, isDark, isEN)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String category, bool isDark, bool isEN) {
    final catItems = _items.where((e) => e.category == category).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(category, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white54 : Colors.grey[600])),
        ),
        ...catItems.map((item) {
          final idx = _items.indexOf(item);
          final checked = _checked.contains(idx);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3345) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: item.essential ? Border.all(color: const Color(0xFF2C6E8A).withOpacity(0.3)) : null,
            ),
            child: CheckboxListTile(
              value: checked,
              onChanged: (v) => setState(() => v! ? _checked.add(idx) : _checked.remove(idx)),
              title: Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    isEN ? item.nameEN : item.nameTR,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: checked ? (isDark ? Colors.white38 : Colors.grey) : (isDark ? Colors.white : const Color(0xFF1A2B35)),
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item.essential) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: const Color(0xFF2C6E8A).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(isEN ? 'Essential' : 'Şart', style: const TextStyle(fontSize: 9, color: Color(0xFF2C6E8A), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
              activeColor: const Color(0xFF2C6E8A),
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
          );
        }),
      ],
    );
  }

  String _emoji(String condition) {
    switch (condition) {
      case 'clear': return '☀️';
      case 'clouds': return '⛅';
      case 'rain': return '🌧️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }
}
