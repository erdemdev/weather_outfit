import 'package:flutter/material.dart';
import '../services/countdown_service.dart';
import '../l10n/app_localizations.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  List<CountdownEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final events = await CountdownService.getEvents();
    setState(() => _events = events);
  }

  void _addEvent() {
    final titleCtrl = TextEditingController();
    final outfitCtrl = TextEditingController();
    String emoji = '🎉';
    DateTime date = DateTime.now().add(const Duration(days: 7));
    final isEN = AppStrings.lang == 'en';

    final emojis = ['🎉', '💒', '🎓', '✈️', '🎂', '💼', '❤️', '🏆', '🎄', '🎃'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEN ? 'Add Event' : 'Etkinlik Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: isEN ? 'Event name' : 'Etkinlik adı',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setDialogState(() => emoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: emoji == e ? const Color(0xFF2C6E8A).withValues(alpha: 0.2) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text('${date.day}.${date.month}.${date.year}'),
                  subtitle: Text(isEN ? 'Event date' : 'Etkinlik tarihi'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) setDialogState(() => date = picked);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: outfitCtrl,
                  decoration: InputDecoration(
                    labelText: isEN ? 'Outfit plan (optional)' : 'Kombin planı (opsiyonel)',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEN ? 'Cancel' : 'İptal')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.isNotEmpty) {
                  await CountdownService.addEvent(CountdownEvent(
                    title: titleCtrl.text,
                    emoji: emoji,
                    eventDate: date,
                    outfitNote: outfitCtrl.text.isNotEmpty ? outfitCtrl.text : null,
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
    final upcoming = _events.where((e) => !e.isPast).toList();
    final past = _events.where((e) => e.isPast).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Event Countdown' : 'Etkinlik Geri Sayım'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: const Color(0xFF2C6E8A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _events.isEmpty
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  isEN ? 'No events yet' : 'Henüz etkinlik yok',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                ),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  // Feature the next event big
                  _buildBigCard(upcoming.first, isDark, isEN),
                  const SizedBox(height: 16),
                  if (upcoming.length > 1) ...[
                    Text(
                      isEN ? 'Upcoming' : 'Yaklaşan',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A2B35),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...upcoming.skip(1).map((e) => _buildSmallCard(e, isDark, isEN)),
                  ],
                ],
                if (past.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    isEN ? 'Past Events' : 'Geçmiş Etkinlikler',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...past.map((e) => _buildSmallCard(e, isDark, isEN, isPast: true)),
                ],
              ],
            ),
    );
  }

  Widget _buildBigCard(CountdownEvent event, bool isDark, bool isEN) {
    final days = event.daysLeft;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2C6E8A).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Text(event.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            '$days',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          Text(
            isEN ? (days == 1 ? 'day left' : 'days left') : 'gün kaldı',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            '${event.eventDate.day}.${event.eventDate.month}.${event.eventDate.year}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          if (event.outfitNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('👗', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.outfitNote!, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallCard(CountdownEvent event, bool isDark, bool isEN, {bool isPast = false}) {
    final realIndex = _events.indexOf(event);
    return Dismissible(
      key: ValueKey('${event.title}_${event.eventDate}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await CountdownService.removeEvent(realIndex);
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3345) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(event.emoji, style: TextStyle(fontSize: 28, color: isPast ? Colors.grey : null)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey : (isDark ? Colors.white : const Color(0xFF1A2B35)),
                  )),
                  if (event.outfitNote != null)
                    Text('👗 ${event.outfitNote}', style: TextStyle(
                      fontSize: 11, color: isDark ? Colors.white38 : Colors.grey,
                    )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isPast ? (isEN ? 'Done' : 'Geçti') : '${event.daysLeft} ${isEN ? 'd' : 'gün'}',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isPast ? Colors.grey : const Color(0xFF2C6E8A),
                  ),
                ),
                Text(
                  '${event.eventDate.day}.${event.eventDate.month}.${event.eventDate.year}',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
