import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, _CalendarEvent> _events = {};
  final _titleController = TextEditingController();
  final _outfitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _outfitController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('calendar_events');
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _events = map.map((k, v) => MapEntry(k, _CalendarEvent.fromJson(v as Map<String, dynamic>)));
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendar_events',
        jsonEncode(_events.map((k, v) => MapEntry(k, v.toJson()))));
  }

  void _addEvent() {
    final isEN = AppStrings.lang == 'en';
    _titleController.clear();
    _outfitController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        String selectedType = 'casual';
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(isEN ? 'Add Event' : 'Etkinlik Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: isEN ? 'Event name' : 'Etkinlik adı',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _outfitController,
                  decoration: InputDecoration(
                    labelText: isEN ? 'Outfit note' : 'Kıyafet notu',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: isEN ? 'Dress code' : 'Kıyafet kodu',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'casual', child: Text(isEN ? '👕 Casual' : '👕 Günlük')),
                    DropdownMenuItem(value: 'formal', child: Text(isEN ? '👔 Formal' : '👔 Resmi')),
                    DropdownMenuItem(value: 'sport', child: Text(isEN ? '🏃 Sport' : '🏃 Spor')),
                    DropdownMenuItem(value: 'party', child: Text(isEN ? '🎉 Party' : '🎉 Parti')),
                    DropdownMenuItem(value: 'business', child: Text(isEN ? '💼 Business' : '💼 İş')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isEN ? 'Cancel' : 'İptal'),
              ),
              FilledButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    final key = _dateKey(_selectedDate);
                    setState(() {
                      _events[key] = _CalendarEvent(
                        title: _titleController.text,
                        outfitNote: _outfitController.text,
                        dressCode: selectedType,
                      );
                    });
                    _saveEvents();
                    Navigator.pop(ctx);
                  }
                },
                child: Text(isEN ? 'Save' : 'Kaydet'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final now = DateTime.now();
    final firstOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday; // 1=Mon

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Outfit Calendar' : 'Kombin Takvimi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          // Month navigator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                  }),
                ),
                Text(
                  '${_monthName(_selectedDate.month, isEN)} ${_selectedDate.year}',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                  }),
                ),
              ],
            ),
          ),

          // Days header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(7, (i) {
                final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
                return Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.get(dayKeys[i]),
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
              ),
              itemCount: 42,
              itemBuilder: (ctx, index) {
                final dayNum = index - startWeekday + 2;
                if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();

                final date = DateTime(_selectedDate.year, _selectedDate.month, dayNum);
                final key = _dateKey(date);
                final event = _events[key];
                final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                final isSelected = date.day == _selectedDate.day;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2C6E8A)
                          : isToday
                            ? const Color(0xFF2C6E8A).withOpacity(0.15)
                              : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF1A2B35)),
                          ),
                        ),
                        if (event != null)
                          Text(_dressEmoji(event.dressCode), style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Selected day event
          _buildEventDetail(),
        ],
      ),
    );
  }

  Widget _buildEventDetail() {
    final key = _dateKey(_selectedDate);
    final event = _events[key];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B35) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: event != null
          ? Row(
              children: [
                Text(_dressEmoji(event.dressCode), style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A2B35),
                      )),
                      if (event.outfitNote.isNotEmpty)
                        Text(event.outfitNote, style: TextStyle(
                          fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600],
                        )),
                      Text(
                        _dressLabel(event.dressCode, isEN),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF2C6E8A)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    setState(() => _events.remove(key));
                    _saveEvents();
                  },
                ),
              ],
            )
          : Center(
              child: Text(
                isEN ? 'No event for this day' : 'Bu gün için etkinlik yok',
                style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
              ),
            ),
    );
  }

  String _dressEmoji(String code) {
    switch (code) {
      case 'formal': return '👔';
      case 'sport': return '🏃';
      case 'party': return '🎉';
      case 'business': return '💼';
      default: return '👕';
    }
  }

  String _dressLabel(String code, bool isEN) {
    switch (code) {
      case 'formal': return isEN ? 'Formal' : 'Resmi';
      case 'sport': return isEN ? 'Sport' : 'Spor';
      case 'party': return isEN ? 'Party' : 'Parti';
      case 'business': return isEN ? 'Business' : 'İş';
      default: return isEN ? 'Casual' : 'Günlük';
    }
  }

  String _monthName(int month, bool isEN) {
    if (isEN) {
      const m = ['January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'];
      return m[month - 1];
    }
    const m = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return m[month - 1];
  }
}

class _CalendarEvent {
  final String title;
  final String outfitNote;
  final String dressCode;

  _CalendarEvent({required this.title, required this.outfitNote, required this.dressCode});

  Map<String, dynamic> toJson() => {
        'title': title,
        'outfitNote': outfitNote,
        'dressCode': dressCode,
      };

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) => _CalendarEvent(
        title: json['title'] as String? ?? '',
        outfitNote: json['outfitNote'] as String? ?? '',
        dressCode: json['dressCode'] as String? ?? 'casual',
      );
}
