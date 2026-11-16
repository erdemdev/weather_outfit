import 'package:flutter/material.dart';
import '../services/fashion_tips_service.dart';
import '../l10n/app_localizations.dart';

class FashionTipsScreen extends StatelessWidget {
  const FashionTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final categories = ['weather', 'color', 'body', 'general'];
    final categoryLabels = isEN
        ? {'weather': '🌤️ Weather', 'color': '🎨 Color', 'body': '👤 Body', 'general': '💡 General'}
        : {'weather': '🌤️ Hava', 'color': '🎨 Renk', 'body': '👤 Vücut', 'general': '💡 Genel'};

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(isEN ? 'Fashion Tips' : 'Moda İpuçları'),
          backgroundColor: const Color(0xFF2C6E8A),
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: categories.map((c) => Tab(text: categoryLabels[c])).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((cat) {
            final tips = FashionTipsService.getByCategory(cat);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tips.length,
              itemBuilder: (ctx, i) {
                final tip = tips[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3345) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEN ? tip.titleEN : tip.titleTR,
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A2B35),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEN ? tip.tipEN : tip.tipTR,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
