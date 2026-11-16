import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../l10n/app_localizations.dart';

class OutfitSearchScreen extends StatefulWidget {
  const OutfitSearchScreen({super.key});

  @override
  State<OutfitSearchScreen> createState() => _OutfitSearchScreenState();
}

class _OutfitSearchScreenState extends State<OutfitSearchScreen> {
  List<HistoryEntry> _all = [];
  List<HistoryEntry> _filtered = [];
  final _searchCtrl = TextEditingController();
  String _filterCondition = 'all';
  int? _filterRating;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final all = await HistoryService.getHistory();
    setState(() {
      _all = all;
      _filtered = all;
    });
  }

  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((e) {
        final matchText = query.isEmpty || e.outfitTitle.toLowerCase().contains(query) || e.city.toLowerCase().contains(query);
        final matchCond = _filterCondition == 'all' || e.condition == _filterCondition;
        final matchRating = _filterRating == null || e.rating == _filterRating;
        return matchText && matchCond && matchRating;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Search Outfits' : 'Kombin Ara'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: isEN ? 'Search by name or city...' : 'İsim veya şehir ara...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E3345) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filters
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('all', isEN ? 'All' : 'Tümü', null, isDark),
                _filterChip('clear', '☀️', 'clear', isDark),
                _filterChip('clouds', '⛅', 'clouds', isDark),
                _filterChip('rain', '🌧️', 'rain', isDark),
                _filterChip('snow', '❄️', 'snow', isDark),
                const SizedBox(width: 8),
                ...List.generate(5, (i) {
                  final star = i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text('$star⭐'),
                      selected: _filterRating == star,
                      onSelected: (sel) {
                        setState(() => _filterRating = sel ? star : null);
                        _applyFilters();
                      },
                      selectedColor: const Color(0xFF2C6E8A),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _filterRating == star ? Colors.white : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} ${isEN ? 'results' : 'sonuç'}',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
              ),
            ),
          ),
          // Results
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text(
                    isEN ? 'No matching outfits' : 'Eşleşen kombin yok',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _buildEntry(_filtered[i], isDark, isEN),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label, String? condition, bool isDark) {
    final selected = _filterCondition == (condition ?? 'all');
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _filterCondition = condition ?? 'all');
          _applyFilters();
        },
        selectedColor: const Color(0xFF2C6E8A),
        labelStyle: TextStyle(fontSize: 12, color: selected ? Colors.white : null),
      ),
    );
  }

  Widget _buildEntry(HistoryEntry entry, bool isDark, bool isEN) {
    final emoji = switch (entry.condition) {
      'clear' => '☀️',
      'clouds' => '⛅',
      'rain' => '🌧️',
      'drizzle' => '🌦️',
      'thunderstorm' => '⛈️',
      'snow' => '❄️',
      _ => '🌤️',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.outfitTitle, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                )),
                Text(
                  '${entry.city} • ${entry.temperature.round()}°C • ${entry.date.day}.${entry.date.month}.${entry.date.year}',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ),
          if (entry.rating != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2C6E8A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('⭐ ${entry.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
