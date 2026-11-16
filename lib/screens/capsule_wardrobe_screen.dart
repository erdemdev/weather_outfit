import 'package:flutter/material.dart';
import '../services/capsule_wardrobe_service.dart';
import '../services/wardrobe_service.dart';
import '../l10n/app_localizations.dart';

class CapsuleWardrobeScreen extends StatefulWidget {
  const CapsuleWardrobeScreen({super.key});

  @override
  State<CapsuleWardrobeScreen> createState() => _CapsuleWardrobeScreenState();
}

class _CapsuleWardrobeScreenState extends State<CapsuleWardrobeScreen> {
  List<WardrobeItem> _capsuleItems = [];
  List<CapsuleOutfit> _combos = [];
  int _totalCombos = 0;
  int _score = 0;
  List<String> _tips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCapsule();
  }

  Future<void> _loadCapsule() async {
    final result = await CapsuleWardrobeService.generateCapsule();
    final tips = await CapsuleWardrobeService.getTips();
    setState(() {
      _capsuleItems = result['items'] as List<WardrobeItem>;
      _combos = result['combos'] as List<CapsuleOutfit>;
      _totalCombos = result['totalCombos'] as int? ?? 0;
      _score = result['score'] as int? ?? 0;
      _tips = tips;
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
        title: Text(isEN ? 'Capsule Wardrobe' : 'Kapsül Dolap'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _capsuleItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom, size: 64, color: isDark ? Colors.white30 : Colors.black26),
                      const SizedBox(height: 16),
                      Text(isEN ? 'Add items to your wardrobe first' : 'Önce dolabına parça ekle',
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.black45)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Stats header
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
                          const Text('📋', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(
                            isEN ? 'Your Capsule Wardrobe' : 'Kapsül Dolabın',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(children: [
                                Text('${_capsuleItems.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(isEN ? 'Items' : 'Parça', style: const TextStyle(color: Colors.white70)),
                              ]),
                              Container(width: 1, height: 40, color: Colors.white24),
                              Column(children: [
                                Text('$_totalCombos', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(isEN ? 'Combos' : 'Kombin', style: const TextStyle(color: Colors.white70)),
                              ]),
                              Container(width: 1, height: 40, color: Colors.white24),
                              Column(children: [
                                Row(children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < _score ? Colors.amber : Colors.white24))),
                                Text(isEN ? 'Score' : 'Puan', style: const TextStyle(color: Colors.white70)),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Capsule items
                    Text(isEN ? 'Essential Items' : 'Temel Parçalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _capsuleItems.map((item) => Chip(
                        avatar: Text(item.emoji, style: const TextStyle(fontSize: 16)),
                        label: Text(item.name),
                        backgroundColor: Color(item.colorValue).withValues(alpha: 0.15),
                        side: BorderSide(color: Color(item.colorValue).withValues(alpha: 0.3)),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Example combos
                    if (_combos.isNotEmpty) ...[
                      Text(isEN ? 'Example Combinations' : 'Örnek Kombinler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      ..._combos.take(5).map((combo) => Card(
                        color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${combo.emoji} ${combo.title}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                              const SizedBox(height: 8),
                              ...combo.itemNames.map((name) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('  $name', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                              )),
                            ],
                          ),
                        ),
                      )),
                    ],
                    const SizedBox(height: 24),
                    // Tips
                    if (_tips.isNotEmpty) ...[
                      Text(isEN ? 'Tips' : 'İpuçları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      ..._tips.map((tip) => Card(
                        color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(tip, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                        ),
                      )),
                    ],
                  ],
                ),
    );
  }
}
