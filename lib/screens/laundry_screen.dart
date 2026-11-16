import 'package:flutter/material.dart';
import '../services/laundry_service.dart';
import '../services/wardrobe_service.dart';
import '../l10n/app_localizations.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> {
  List<LaundryItem> _items = [];
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await LaundryService.getItems();
    setState(() => _items = items);
  }

  void _addFromWardrobe() async {
    final isEN = AppStrings.lang == 'en';
    final wardrobeItems = await WardrobeService.getItems();
    final existingNames = _items.map((i) => i.itemName).toSet();
    final available = wardrobeItems.where((w) => !existingNames.contains(w.name)).toList();

    if (!mounted) return;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEN ? 'All wardrobe items already tracked' : 'Tüm dolap parçaları zaten takipte'),
      ));
      return;
    }

    final selected = await showDialog<List<int>>(
      context: context,
      builder: (ctx) {
        final chosen = <int>{};
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(isEN ? 'Add from Wardrobe' : 'Dolaptan Ekle'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (ctx, i) {
                  final item = available[i];
                  return CheckboxListTile(
                    value: chosen.contains(i),
                    onChanged: (v) => setDialogState(() {
                      if (v == true) {
                        chosen.add(i);
                      } else {
                        chosen.remove(i);
                      }
                    }),
                    title: Text('${item.emoji} ${item.name}'),
                    subtitle: Text(item.category),
                    secondary: Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: Color(item.colorValue),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEN ? 'Cancel' : 'İptal')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, chosen.toList()),
                child: Text(isEN ? 'Add (${chosen.length})' : 'Ekle (${chosen.length})'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      for (final i in selected) {
        final w = available[i];
        await LaundryService.addItem(LaundryItem(
          itemName: w.name,
          category: w.category,
          colorValue: w.colorValue,
          status: LaundryStatus.clean,
          lastChanged: DateTime.now(),
        ));
      }
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    final filtered = _filter == 'all'
        ? _items
        : _items.where((i) => i.status.name == _filter).toList();

    final cleanCount = _items.where((i) => i.status == LaundryStatus.clean).length;
    final dirtyCount = _items.where((i) => i.status == LaundryStatus.dirty).length;
    final washingCount = _items.where((i) => i.status == LaundryStatus.washing).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Laundry Tracker' : 'Çamaşır Takibi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFromWardrobe,
        backgroundColor: const Color(0xFF2C6E8A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _statChip('✅', '$cleanCount', isEN ? 'Clean' : 'Temiz', Colors.green, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _statChip('🧺', '$dirtyCount', isEN ? 'Dirty' : 'Kirli', Colors.orange, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _statChip('🔄', '$washingCount', isEN ? 'Washing' : 'Yıkamada', Colors.blue, isDark)),
              ],
            ),
          ),
          // Filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterBtn('all', isEN ? 'All' : 'Tümü', isDark),
                _filterBtn('clean', '✅ ${isEN ? 'Clean' : 'Temiz'}', isDark),
                _filterBtn('dirty', '🧺 ${isEN ? 'Dirty' : 'Kirli'}', isDark),
                _filterBtn('washing', '🔄 ${isEN ? 'Washing' : 'Yıkamada'}', isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(
                    isEN ? 'No items to show' : 'Gösterilecek parça yok',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final realIndex = _items.indexOf(item);
                      return _buildItemTile(item, realIndex, isDark, isEN);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$emoji $value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _filterBtn(String key, String label, bool isDark) {
    final selected = _filter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = key),
        selectedColor: const Color(0xFF2C6E8A),
        labelStyle: TextStyle(fontSize: 12, color: selected ? Colors.white : null),
      ),
    );
  }

  Widget _buildItemTile(LaundryItem item, int index, bool isDark, bool isEN) {
    final (statusEmoji, statusColor) = switch (item.status) {
      LaundryStatus.clean => ('✅', Colors.green),
      LaundryStatus.dirty => ('🧺', Colors.orange),
      LaundryStatus.washing => ('🔄', Colors.blue),
    };

    return Dismissible(
      key: ValueKey('${item.itemName}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await LaundryService.removeItem(index);
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
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  )),
                  Text(item.category, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
                ],
              ),
            ),
            // Status buttons
            PopupMenuButton<LaundryStatus>(
              onSelected: (status) async {
                await LaundryService.updateStatus(index, status);
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$statusEmoji ${isEN ? item.status.name : _statusTR(item.status)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(value: LaundryStatus.clean, child: Text(isEN ? '✅ Clean' : '✅ Temiz')),
                PopupMenuItem(value: LaundryStatus.dirty, child: Text(isEN ? '🧺 Dirty' : '🧺 Kirli')),
                PopupMenuItem(value: LaundryStatus.washing, child: Text(isEN ? '🔄 Washing' : '🔄 Yıkamada')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusTR(LaundryStatus s) => switch (s) {
    LaundryStatus.clean => 'Temiz',
    LaundryStatus.dirty => 'Kirli',
    LaundryStatus.washing => 'Yıkamada',
  };
}
