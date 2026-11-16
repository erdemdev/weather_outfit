import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../l10n/app_localizations.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<BudgetEntry> _entries = [];
  double _monthlyTotal = 0;
  double _allTotal = 0;
  Map<String, double> _categorySpending = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final entries = await BudgetService.getEntries();
    final monthly = await BudgetService.getMonthlyTotal();
    final total = await BudgetService.getTotalSpent();
    final catSpend = await BudgetService.getCategorySpending();
    setState(() {
      _entries = entries;
      _monthlyTotal = monthly;
      _allTotal = total;
      _categorySpending = catSpend;
    });
  }

  void _addEntry() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'üst';
    final isEN = AppStrings.lang == 'en';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEN ? 'Add Expense' : 'Harcama Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isEN ? 'Item name' : 'Kıyafet adı',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isEN ? 'Price (₺)' : 'Fiyat (₺)',
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
                final price = double.tryParse(priceCtrl.text);
                if (nameCtrl.text.isNotEmpty && price != null && price > 0) {
                  await BudgetService.addEntry(BudgetEntry(
                    itemName: nameCtrl.text,
                    category: category,
                    price: price,
                    date: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Budget Tracker' : 'Bütçe Takibi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: const Color(0xFF2C6E8A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _summaryCard(
                isEN ? 'This Month' : 'Bu Ay',
                '₺${_monthlyTotal.toStringAsFixed(0)}',
                Icons.calendar_today_rounded,
                const Color(0xFF2C6E8A),
                isDark,
              )),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard(
                isEN ? 'Total' : 'Toplam',
                '₺${_allTotal.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                const Color(0xFF6B4FCF),
                isDark,
              )),
            ],
          ),
          if (_categorySpending.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCategoryBreakdown(isDark, isEN),
          ],
          const SizedBox(height: 16),
          Text(
            isEN ? 'Recent Expenses' : 'Son Harcamalar',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 8),
          if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(
                isEN ? 'No expenses yet' : 'Henüz harcama yok',
                style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
              )),
            )
          else
            ..._entries.take(20).map((e) => _buildEntryTile(e, isDark, isEN)),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(bool isDark, bool isEN) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEN ? '📊 By Category' : '📊 Kategoriye Göre', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A2B35),
          )),
          const SizedBox(height: 12),
          ..._categorySpending.entries.map((e) {
            final pct = _allTotal > 0 ? e.value / _allTotal : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 70, child: Text(e.key, style: TextStyle(
                    fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600],
                  ))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                        color: const Color(0xFF2C6E8A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('₺${e.value.toStringAsFixed(0)}', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEntryTile(BudgetEntry entry, bool isDark, bool isEN) {
    final emoji = switch (entry.category) {
      'üst' => '👕',
      'alt' => '👖',
      'dış giyim' => '🧥',
      'ayakkabı' => '👟',
      'aksesuar' => '🧢',
      _ => '📦',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.itemName, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                )),
                Text(
                  '${entry.date.day}.${entry.date.month}.${entry.date.year}',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ),
          Text('₺${entry.price.toStringAsFixed(0)}', style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C6E8A),
          )),
        ],
      ),
    );
  }
}
