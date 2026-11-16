import 'package:flutter/material.dart';
import '../services/event_outfit_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../l10n/app_localizations.dart';

class EventOutfitScreen extends StatefulWidget {
  const EventOutfitScreen({super.key});

  @override
  State<EventOutfitScreen> createState() => _EventOutfitScreenState();
}

class _EventOutfitScreenState extends State<EventOutfitScreen> {
  WeatherData? _weather;
  OutfitRecommendation? _outfit;
  String? _selectedEvent;

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

  void _selectEvent(String eventId) {
    if (_weather == null) return;
    setState(() {
      _selectedEvent = eventId;
      _outfit = EventOutfitService.getRecommendation(eventId, _weather!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Event Outfit' : 'Etkinlik Kombini'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isEN ? 'What\'s the occasion?' : 'Etkinlik ne?',
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: EventOutfitService.events.map((e) {
                    final id = e['id'] as String;
                    final selected = _selectedEvent == id;
                    return GestureDetector(
                      onTap: () => _selectEvent(id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2C6E8A)
                              : (isDark ? const Color(0xFF1E3345) : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: selected ? null : Border.all(
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(e['emoji'] as String, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              isEN ? e['en'] as String : e['tr'] as String,
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500,
                                color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
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
          if (o.tip.isNotEmpty) ...[
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
          if (o.alerts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...o.alerts.map((a) => Text(a, style: const TextStyle(color: Colors.yellowAccent, fontSize: 12))),
          ],
        ],
      ),
    );
  }
}
