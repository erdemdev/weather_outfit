import 'package:flutter/material.dart';
import '../services/shopping_list_service.dart';
import '../services/wardrobe_analysis_service.dart';
import '../l10n/app_localizations.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _items = [];
  double _estimatedTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await ShoppingListService.getItems();
    final total = await ShoppingListService.getEstimatedTotal();
    setState(() {
      _items = items;
      _estimatedTotal = total;
    });
  }

  void _addItem() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'üst';
    final isEN = AppStrings.lang == 'en';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEN ? 'Add Item' : 'Parça Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isEN ? 'Item name' : 'Parça adı',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isEN ? 'Estimated price (₺)' : 'Tahmini fiyat (₺)',
                  border: const OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: isEN ? 'Category' : 'Kategori',
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'üst', child: Text('👕 Üst')),
                  DropdownMenuItem(value: 'alt', child: Text('👖 Alt')),
                  DropdownMenuItem(value: 'dış giyim', child: Text('🧥 Dış Giyim')),
                  DropdownMenuItem(value: 'ayakkabı', child: Text('👟 Ayakkabı')),
                  DropdownMenuItem(value: 'aksesuar', child: Text('🧢 Aksesuar')),
                ],
                onChanged: (v) => setDialogState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEN ? 'Cancel' : 'İptal')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final price = double.tryParse(priceCtrl.text);
                  await ShoppingListService.addItem(ShoppingItem(
                    name: nameCtrl.text,
                    category: category,
                    emoji: _catEmoji(category),
                    estimatedPrice: price,
                  ));
                  await _loadData();
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: Text(isEN ? 'Add' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _autoGenerate() async {
    final isEN = AppStrings.lang == 'en';
    final gaps = await WardrobeAnalysisService.analyzeGaps();
    if (gaps.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEN ? 'No gaps found in wardrobe!' : 'Dolapta eksik bulunamadı!'),
        ));
      }
      return;
    }
    for (final gap in gaps) {
      await ShoppingListService.addItem(ShoppingItem(
        name: isEN ? gap.messageEN : gap.messageTR,
        category: gap.category,
        emoji: gap.emoji,
      ));
    }
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEN ? '${gaps.length} items added from gap analysis' : '${gaps.length} eksik parça eklendi'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final purchased = _items.where((i) => i.purchased).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Shopping List' : 'Alışveriş Listesi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high_rounded),
            onPressed: _autoGenerate,
            tooltip: isEN ? 'Auto-generate from gaps' : 'Eksiklerden otomatik oluştur',
          ),
          if (purchased > 0)
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              onPressed: () async {
                await ShoppingListService.clearPurchased();
                _loadData();
              },
              tooltip: isEN ? 'Clear purchased' : 'Alınanları temizle',
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: const Color(0xFF2C6E8A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Summary
          if (_estimatedTotal > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEN ? 'Estimated Total' : 'Tahmini Toplam',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '₺${_estimatedTotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$purchased/${_items.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: _items.isEmpty
                ? Center(child: Text(
                    isEN ? 'Shopping list is empty' : 'Alışveriş listesi boş',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) => _buildItemTile(_items[i], i, isDark, isEN),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ShoppingItem item, int index, bool isDark, bool isEN) {
    return Dismissible(
      key: ValueKey('${item.name}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await ShoppingListService.removeItem(index);
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3345) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                await ShoppingListService.togglePurchased(index);
                _loadData();
              },
              child: Icon(
                item.purchased ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: item.purchased ? Colors.green : (isDark ? Colors.white38 : Colors.grey),
              ),
            ),
            const SizedBox(width: 10),
            Text(item.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  decoration: item.purchased ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (item.estimatedPrice != null)
              Text('₺${item.estimatedPrice!.toStringAsFixed(0)}', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: const Color(0xFF2C6E8A),
                decoration: item.purchased ? TextDecoration.lineThrough : null,
              )),
          ],
        ),
      ),
    );
  }

  String _catEmoji(String cat) => switch (cat) {
    'üst' => '👕',
    'alt' => '👖',
    'dış giyim' => '🧥',
    'ayakkabı' => '👟',
    'aksesuar' => '🧢',
    _ => '📦',
  };
}
