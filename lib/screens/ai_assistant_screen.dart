import 'package:flutter/material.dart';
import '../services/ai_style_service.dart';
import '../l10n/app_localizations.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  List<StyleInsight> _insights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final insights = await AiStyleService.analyzeStyle();
    setState(() {
      _insights = insights;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'AI Style Assistant' : 'AI Stil Asistanı'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C6E8A), Color(0xFF1A4A5E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🧠', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        isEN ? 'AI Style Analysis' : 'AI Stil Analizi',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEN
                            ? 'Personalized insights based on your outfit history and wardrobe'
                            : 'Kombin geçmişin ve dolabına göre kişisel analizler',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Insights
                ...List.generate(_insights.length, (index) {
                  final insight = _insights[index];
                  return _buildInsightCard(insight, index, isDark, isEN);
                }),
              ],
            ),
    );
  }

  Widget _buildInsightCard(StyleInsight insight, int index, bool isDark, bool isEN) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 100),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Card(
        color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(insight.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEN ? insight.titleEN : insight.titleTR,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isEN ? insight.descEN : insight.descTR,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 12),
              // Confidence bar
              Row(
                children: [
                  Text(isEN ? 'Confidence' : 'Güven', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black26)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: insight.confidence,
                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation(
                          insight.confidence > 0.7
                              ? const Color(0xFF4CAF50)
                              : insight.confidence > 0.4
                                  ? const Color(0xFFFFC107)
                                  : const Color(0xFFFF9800),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(insight.confidence * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black45)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
