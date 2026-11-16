import 'package:flutter/material.dart';
import '../services/weather_alert_service.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class WeatherAlertScreen extends StatefulWidget {
  final WeatherData? weather;
  const WeatherAlertScreen({super.key, this.weather});

  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  bool _enabled = true;
  List<WeatherAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await WeatherAlertService.isEnabled();
    final alerts = widget.weather != null ? WeatherAlertService.checkAlerts(widget.weather!) : <WeatherAlert>[];
    setState(() {
      _enabled = enabled;
      _alerts = alerts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Weather Alerts' : 'Hava Alarmları'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        actions: [
          Switch(
            value: _enabled,
            onChanged: (v) async {
              await WeatherAlertService.setEnabled(v);
              setState(() => _enabled = v);
            },
            activeThumbColor: Colors.white,
          ),
        ],
      ),
      body: !_enabled
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔕', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(isEN ? 'Alerts disabled' : 'Alarmlar kapalı', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey)),
              ],
            ))
          : _alerts.isEmpty
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(isEN ? 'No alerts right now' : 'Şu anda alarm yok', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey)),
                    const SizedBox(height: 8),
                    Text(isEN ? 'Everything looks good!' : 'Her şey yolunda!', style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[400])),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _alerts.length,
                  itemBuilder: (_, i) => _buildAlertCard(_alerts[i], isDark, isEN),
                ),
    );
  }

  Widget _buildAlertCard(WeatherAlert alert, bool isDark, bool isEN) {
    final color = _alertColor(alert.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(alert.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEN ? alert.titleEN : alert.titleTR,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35)),
                ),
                const SizedBox(height: 4),
                Text(
                  isEN ? alert.descEN : alert.descTR,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '⏰ ${alert.hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _alertColor(String type) {
    switch (type) {
      case 'rain_start': return Colors.blue;
      case 'snow_start': return Colors.cyan;
      case 'temp_drop': return Colors.orange;
      case 'high_wind': return Colors.teal;
      case 'high_uv': return Colors.amber;
      default: return const Color(0xFF2C6E8A);
    }
  }
}
