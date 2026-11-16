import 'package:flutter/material.dart';
import '../services/combo_generator_service.dart';
import '../l10n/app_localizations.dart';

class ComboGeneratorScreen extends StatefulWidget {
  const ComboGeneratorScreen({super.key});

  @override
  State<ComboGeneratorScreen> createState() => _ComboGeneratorScreenState();
}

class _ComboGeneratorScreenState extends State<ComboGeneratorScreen> {
  List<GeneratedCombo> _combos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    final combos = await ComboGeneratorService.generate(maxResults: 8);
    setState(() {
      _combos = combos;
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
        title: Text(isEN ? 'Combo Generator' : 'Kombin Oluşturucu'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _generate,
            tooltip: isEN ? 'Regenerate' : 'Yenile',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _combos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👕', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      Text(
                        isEN
                            ? 'Add more items to wardrobe first\n(Need tops + bottoms)'
                            : 'Önce dolaba parça ekle\n(Üst + alt gerekli)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _combos.length,
                  itemBuilder: (ctx, i) => _buildComboCard(_combos[i], i, isDark, isEN),
                ),
    );
  }

  Widget _buildComboCard(GeneratedCombo combo, int index, bool isDark, bool isEN) {
    final scorePercent = (combo.harmonyScore * 100).round();
    final scoreColor = combo.harmonyScore > 0.7
        ? Colors.green
        : (combo.harmonyScore > 0.4 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C6E8A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2C6E8A)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎨 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '$scorePercent%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scoreColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items
          ...combo.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.name, style: TextStyle(
                    fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  )),
                ),
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: Color(item.colorValue),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.category,
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          )),
          // Color palette
          const SizedBox(height: 8),
          Row(
            children: combo.items.map((item) => Container(
              width: 16, height: 16, margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 0.5),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
