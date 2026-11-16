import 'package:flutter/material.dart';
import '../services/wardrobe_service.dart';
import '../l10n/app_localizations.dart';

class TagFilterScreen extends StatefulWidget {
  const TagFilterScreen({super.key});

  @override
  State<TagFilterScreen> createState() => _TagFilterScreenState();
}

class _TagFilterScreenState extends State<TagFilterScreen> {
  List<WardrobeItem> _items = [];
  String _selectedTag = 'all';

  static const _tags = [
    {'id': 'all', 'emoji': '📦', 'tr': 'Tümü', 'en': 'All'},
    {'id': 'formal', 'emoji': '👔', 'tr': 'Resmi', 'en': 'Formal'},
    {'id': 'casual', 'emoji': '😎', 'tr': 'Günlük', 'en': 'Casual'},
    {'id': 'sporty', 'emoji': '🏃', 'tr': 'Spor', 'en': 'Sporty'},
    {'id': 'party', 'emoji': '🎉', 'tr': 'Parti', 'en': 'Party'},
    {'id': 'outdoor', 'emoji': '🌿', 'tr': 'Outdoor', 'en': 'Outdoor'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await WardrobeService.getItems();
    setState(() => _items = items);
  }

  // Smart tag inference based on item name and category
  String _inferTag(WardrobeItem item) {
    final name = item.name.toLowerCase();
    // Formal
    if (name.contains('gömlek') || name.contains('shirt') || name.contains('blazer') ||
        name.contains('takım') || name.contains('suit') || name.contains('kravat') ||
        name.contains('tie') || name.contains('klasik') || name.contains('formal')) {
      return 'formal';
    }
    // Sporty
    if (name.contains('spor') || name.contains('sport') || name.contains('sneaker') ||
        name.contains('eşofman') || name.contains('jogger') || name.contains('şort') ||
        name.contains('short') || name.contains('track')) {
      return 'sporty';
    }
    // Party
    if (name.contains('parti') || name.contains('party') || name.contains('payetli') ||
        name.contains('sequin') || name.contains('abiye') || name.contains('gece') ||
        name.contains('evening')) {
      return 'party';
    }
    // Outdoor
    if (name.contains('mont') || name.contains('jacket') || name.contains('bot') ||
        name.contains('boot') || name.contains('yağmurluk') || name.contains('raincoat') ||
        name.contains('outdoor') || name.contains('hiking')) {
      return 'outdoor';
    }
    // Default to casual
    return 'casual';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    final filtered = _selectedTag == 'all'
        ? _items
        : _items.where((i) => _inferTag(i) == _selectedTag).toList();

    // Tag counts
    final tagCounts = <String, int>{};
    for (final item in _items) {
      final tag = _inferTag(item);
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Clothing Tags' : 'Kıyafet Etiketleri'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tag chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _tags.map((tag) {
                final id = tag['id'] as String;
                final selected = _selectedTag == id;
                final count = id == 'all' ? _items.length : (tagCounts[id] ?? 0);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTag = id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF2C6E8A)
                            : (isDark ? const Color(0xFF1E3345) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: selected ? null : Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag['emoji'] as String, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            isEN ? tag['en'] as String : tag['tr'] as String,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              color: selected ? Colors.white70 : (isDark ? Colors.white38 : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Results
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(
                    isEN ? 'No items with this tag' : 'Bu etiketle parça yok',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  ))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildItemCard(filtered[i], isDark, isEN),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(WardrobeItem item, bool isDark, bool isEN) {
    final tag = _inferTag(item);
    final tagData = _tags.firstWhere((t) => t['id'] == tag);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Color(item.colorValue),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C6E8A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${tagData['emoji']} ${isEN ? tagData['en'] : tagData['tr']}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF2C6E8A)),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(item.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.category,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
          ),
        ],
      ),
    );
  }
}
